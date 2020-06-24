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
  # TODO: Check if this is needed or not.
  # String $ssl_cn = 'fulcrum.org',
  String $docroot = '/hydra/heliotrope-production/current/public'
) {
  $servername = 'www.fulcrum.org'
  $serveraliases = ['fulcrum.www.lib.umich.edu', 'fulcrum.lib.umich.edu']
  $logging_prefix = 'heliotrope-production'

  file { "${apache::params::logroot}/${logging_prefix}":
    ensure => 'directory',
  }

  nebula::apache::www_lib_vhost { 'fulcrum-http':
    priority       => '13',
    servername     => $servername,
    serveraliases  => $serveraliases,
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
        require  => $nebula::profile::www_lib::apache::default_access,
      },
    ],
  }

  nebula::apache::www_lib_vhost { 'fulcrum-https':
    priority        => '13',
    servername      => $servername,
    serveraliases   => $serveraliases,
    docroot         => $docroot,
    logging_prefix  => "${logging_prefix}/",

    ssl             => false,
    port_override   => 443,
    usertrack       => true,

    setenv          => ['HTTPS on'],

    rewrites        => [
      {
        comment      => 'Serve static assets through apache',
        rewrite_cond => ['/hydra/heliotrope-production/current/public/$1 -d [OR]', '/hydra/heliotrope-production/current/public/$1 -f'],
        rewrite_rule => '^/(.*)$  /hydra/heliotrope-production/current/public/$1 [L]',
      },
      {
        comment      => 'Reverse proxy application to app hostname and port',
        rewrite_cond => ['%{REQUEST_URI} !^/cosign/valid', '%{REQUEST_URI} !^/Shibboleth.sso'],
        rewrite_rule => '^(/.*)$ http://app-heliotrope-production:30399$1 [P]',
      },
    ],

    directories     => [
      {
        provider => 'location',
        path     => '/',
        require  => $nebula::profile::www_lib::apache::default_access,
      },
      {
        provider       => 'directory',
        path           => $docroot,
        options        => 'FollowSymlinks',
        allow_override => 'None',
        require        => $nebula::profile::www_lib::apache::default_access,
      },
    ],

    # TODO: Review Shib headers for apache 2.4
    request_headers => [
      # Explicitly forward attributes extracted via Shibboleth
      'set X-Shib-Persistent-ID %{persistent-id}e',
      'set X-Shib-eduPersonPrincipalName %{eppn}e',
      'set X-Shib-displayName %{displayName}e',
      'set X-Shib-mail %{email}e',
      'set X-Shib-eduPersonScopedAffiliation %{affiliation}e',
      'set X-Shib-Authentication-Method %{Shib-Authentication-Method}e',
      'set X-Shib-AuthnContext-Class %{Shib-AuthnContext-Class}e',
      'set X-Shib-Identity-Provider %{Shib-Identity-Provider}e',
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

    custom_fragment => @(EOT)

      # Reverse proxy application to app hostname and port
      ProxyPassReverse / http://app-heliotrope-production:30399/
      # XSendFile settings
      XSendFile on
      XSendFilePath /hydra/heliotrope-production/current/tmp/derivatives
      # Configure Shibboleth for authentication via InCommon partner login
      <Location /Shibboleth.sso>
        SetHandler shib
      </Location> 
      <Location "/">
        AuthType shibboleth
        ShibRequestSetting requireSession 0
        Require shibboleth
      </Location>
    | EOT
  }
}
