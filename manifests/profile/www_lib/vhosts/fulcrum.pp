# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::fulcrum
#
# Fulcrum aka Heliotrope app  virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::fulcrum
class nebula::profile::www_lib::vhosts::fulcrum (
  String $docroot = '/fulcrum/app/current/public',
  String $derivatives_path = '/fulcrum/data/derivatives',
  # Temporary to allow legacy servers use old/new paths in parallel
  String $alt_derivatives_path = '/hydra/heliotrope-production/current/tmp/derivatives',
  String $logging_prefix = 'fulcrum',
  String $app_host = 'app',
  String $app_port = '3000',
  String $servername = 'www.fulcrum.org'
) {
  $authz_base_requires = {
    enforce  => 'all',
    requires => [
      'not env badrobot',
      'not env loadbalancer',
      'all granted'
    ]
  }

  file { "${apache::params::logroot}/${logging_prefix}":
    ensure => 'directory',
  }

  nebula::apache::www_lib_vhost { 'fulcrum-http':
    priority       => '13',
    servername     => $servername,
    docroot        => false,
    logging_prefix => "${logging_prefix}/",
    usertrack      => true,

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ],

    directories    => [
      {
        provider => 'location',
        path     => '/',
        require  => $authz_base_requires,
      },
    ],
  }

  $datacenter_cidrs = lookup('nebula::known_addresses::datacenter').flatten.map |String $cidr| { "ip ${cidr}" }

  nebula::apache::www_lib_vhost { 'fulcrum-https':
    priority        => '13',
    servername      => $servername,
    docroot         => $docroot,
    logging_prefix  => "${logging_prefix}/",

    ssl             => true,
    # ServerName is really www.fulcrum.org, but this cert filename is odd: fulcrum.org.crt
    ssl_cn          => 'fulcrum.org',
    port_override   => 443,
    usertrack       => true,

    setenv          => ['HTTPS on'],

    rewrites        => [
      {
        comment      => 'Serve static assets through apache',
        rewrite_cond => ["${docroot}/\$1 -d [OR]", "${docroot}/\$1 -f"],
        rewrite_rule => "^/(.*)$  ${docroot}/\$1 [L]",
      },
      {
        comment      => 'Proxy metrics requests to Yabeda/Prometheus exporter',
        rewrite_rule => "^/metrics$ http://${app_host}:9394/metrics [P]",
      },
      {
        comment      => 'Reverse proxy application to app hostname and port',
        rewrite_cond => ['%{REQUEST_URI} !^/Shibboleth.sso'],
        rewrite_rule => "^(/.*)$ http://${app_host}:${app_port}\$1 [P]",
      },
    ],

    directories     => [
      {
        provider => 'location',
        path     => '/',
        require  => $authz_base_requires,
      },
      {
        provider       => 'directory',
        path           => $docroot,
        options        => 'FollowSymlinks',
        allow_override => 'None',
        require        => $authz_base_requires,
      },
      {
        provider => 'location',
        path     => '/metrics',
        require  => {
          enforce  => 'any',
          requires => ['local'] + $datacenter_cidrs
        },
      },
    ],

    # TODO: Review Shib headers for apache 2.4
    request_headers => [
      # Remove existing X-Shib- headers before setting new ones based on shib env vars
      'unset X-Shib-Persistent-ID',
      'unset X-Shib-eduPersonPrincipalName',
      'unset X-Shib-displayName',
      'unset X-Shib-mail',
      'unset X-Shib-eduPersonScopedAffiliation',
      'unset X-Shib-Authentication-Method',
      'unset X-Shib-AuthnContext-Class',
      'unset X-Shib-Identity-Provider',
      # Explicitly forward attributes extracted via Shibboleth
      'set X-Shib-Persistent-ID %{persistent-id}e ENV=persistent-id',
      'set X-Shib-eduPersonPrincipalName %{eppn}e ENV=eppn',
      'set X-Shib-displayName %{displayName}e ENV=displayName',
      'set X-Shib-mail %{email}e ENV=email',
      'set X-Shib-eduPersonScopedAffiliation %{affiliation}e ENV=affiliation',
      'set X-Shib-Authentication-Method %{Shib-Authentication-Method}e ENV=Shib-Authentication-Method',
      'set X-Shib-AuthnContext-Class %{Shib-AuthnContext-Class}e ENV=Shib-AuthnContext-Class',
      'set X-Shib-Identity-Provider %{Shib-Identity-Provider}e ENV=Shib-Identity-Provider',
      # Set remote user header to allow app to use http header auth.
      'set X-Remote-User "expr=%{REMOTE_USER}"',
      'set X-Forwarded-Proto "https"',
      'unset X-Forwarded-For',
      # XSendFile settings
      'Set X-Sendfile-Type X-Sendfile',
    ],

    headers         => [
      'set "Strict-Transport-Security" "max-age=3600"',
    ],

    error_documents => [
      { 'error_code' => '404', 'document' => '/404.html' },
      { 'error_code' => '503', 'document' => '/503.html' },
    ],

    custom_fragment => @("EOT")

      # Reverse proxy application to app hostname and port
      ProxyPassReverse / http://${app_host}:${app_port}/
      # XSendFile settings
      XSendFile on
      XSendFilePath ${derivatives_path}
      XSendFilePath ${alt_derivatives_path}
      # Configure Shibboleth for authentication via InCommon partner login
      <Location "/">
        AuthType shibboleth
        ShibRequestSetting requireSession 0
        Require shibboleth
      </Location>
    | EOT
  }
}
