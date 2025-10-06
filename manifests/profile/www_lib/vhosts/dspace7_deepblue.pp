# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::deepblue
#
# deepblue virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::deepblue
class nebula::profile::www_lib::vhosts::dspace7_deepblue (
  String $domain,
  String $prefix,
  String $ssl_cn = 'deepblue.lib.umich.edu',
  String $docroot = '/www/deepblue/web'
) {
  $servername = "${prefix}dspace7.deepblue.${domain}"

  file { "${apache::params::logroot}/dspace7-deepblue":
    ensure => 'directory',
  }

  nebula::apache::www_lib_vhost { 'dspace7-deepblue-http':
    servername     => $servername,
    docroot        => $docroot,
    logging_prefix => 'dspace7-deepblue/',
    usertrack      => true,

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R]'
      },
    ],
  }

  nebula::apache::www_lib_vhost { 'dspace7-deepblue-https':
    servername                  => $servername,
    docroot                     => $docroot,
    logging_prefix              => 'dspace7-deepblue/',

    ssl                         => true,
    ssl_cn                      => $ssl_cn,
    usertrack                   => true,
    auth_openidc                => true,
    auth_openidc_redirect_uri   => 'https://dspace7.deepblue.lib.umich.edu/openid-connect/callback',
    ssl_proxy_machine_cert      => '/etc/ssl/private/machine-cert-deepblue.lib.pem',

    rewrites                    => [
      {
        comment      => 'Deep Blue Repositories home page is on www.lib now',
        rewrite_cond => '%{REQUEST_URI} ^((\/?|/index.html)$|/splash/)',
        rewrite_rule => '^(.*)$	https://www.lib.umich.edu/collections/deep-blue-repositories [redirect=permanent,last]'
      },
      {
        # XXX: Is this really still an issue?
        # Workaround critical DSpace security bug until there is a patch.
        #
        # 2016-03-14 skorner
        comment      => 'Work around critical DSpace security bug from 2016..??',
        rewrite_rule => '^/+themes/.*:.*$ /error [R=permanent,L]',
      },
      {
        comment      => 'Serve static assets through apache',
        rewrite_cond => '/deepbluedata-prod/deepbluedata-production/shared/public/$1 -f',
        rewrite_rule => '^/data/(.*)$  /deepbluedata-prod/deepbluedata-production/shared/public/$1 [L]',
      },
      {
        comment      => 'Deep Blue Data',
        rewrite_cond => '%{ENV:badrobot} !(^true$)',
        rewrite_rule => '^(/data.*)$ http://app-deepbluedata:30060$1 [P]',
      },
      {
        comment      => 'Deep Blue Documents; dont proxy auth_oidc',
        rewrite_cond => ['%{ENV:badrobot} !(^true$)', '%{REQUEST_URI} !^(/openid-connect)'],
        rewrite_rule => '^(.*)$ https://production.deepblue-documents.lib.umich.edu:8443$1 [P]',
      },
      {
        comment      => 'Deep Blue Preservation redirect',
        rewrite_rule => '^/static/about/deepbluepreservation.html https://www.lib.umich.edu/about-us/policies/digital-repository-services-digital-preservation-policy/registered-formats-and [R=permanent,L]',
      },
      {
        comment      => 'new path in DSpace 7 REST-API',
        rewrite_rule => '^/RESTapi https://backend.production.deepblue-documents.lib.mich.edu/rest [R=permanent,L]',
      },
      {
        comment      => 'new path in DSpace 7 for OAI',
        rewrite_rule => '^/dspace-oai https://backend.production.deepblue-documents.lib.mich.edu/oai [R=permanent,L]',
      },
      {
        comment      => 'new path in DSpace 7 for SWORDV2',
        rewrite_rule => '^/swordv2 https://backend.production.deepblue-documents.lib.mich.edu/swordv2 [R=permanent,L]',
      },
    ],

    directories                 => [
      {
        provider       => 'directory',
        path           => $docroot,
        options        => 'None',
        allow_override => 'None',
        require        => $nebula::profile::www_lib::apache::default_access,
      },
      {
        # Block access to the DSpace metadata and DRI services.
        # Per blancoj on 2016-04-21 skorner
        provider => 'locationmatch',
        path     => '^/(metadata|DRI|contact|feedback)(.*)',
        # XXX: Before this allowed a single particular IP address that no
        # longer appears to be in use
        require  => 'all denied'
      },
      {
        provider        => 'location',
        path            => '/',
        auth_type       => 'openid-connect',
        auth_require    => 'valid-user',
        custom_fragment => @(EOT)
        OIDCUnAuthAction pass
        | EOT
      },
      {
        provider        => 'locationmatch',
        path            => '^/data/login',
        auth_type       => 'openid-connect',
        auth_require    => 'valid-user',
        custom_fragment => @(EOT)
        OIDCUnAuthAction auth true
        | EOT
      },
      {
        provider       => 'directory',
        path           => '/deepbluedata-prod/deepbluedata-production/shared/public',
        options        => 'FollowSymlinks',
        allow_override => 'None',
        access         => $nebula::profile::www_lib::apache::default_access
      },
    ],

    request_headers             => [
      # Setting remote user for 2.4
      'set X-Remote-User "expr=%{REMOTE_USER}"',
      # Fix redirects being sent to non ssl url (https -> http)
      'set X-Forwarded-Proto "https"',
      #Set original host name of the request.
      'set X-Forwarded-Host "dspace7.deepblue.lib.umich.edu"',
      # Remove existing X-Forwarded-For headers; mod_proxy will automatically add the correct one.
      'unset X-Forwarded-For',
    ],

    headers                     => [
      'set "Strict-Transport-Security" "max-age=3600"',
      'set "X-Frame-Options" "SAMEORIGIN"',
    ],

    ssl_proxyengine             => true,
    ssl_proxy_check_peer_name   => 'on',
    ssl_proxy_check_peer_expire => 'on',

      ## Redirect Deep Blue Data to an outage
      ##    RewriteEngine On
      ##    RewriteRule   ^/data(.*)$   http://www.lib.umich.edu/outages/deep-blue-data-0     [redirect,noescape,last]

    custom_fragment             => @(EOT)
      ProxyPassReverse /data https://app-deepbluedata.deepblue.lib.umich.edu:30060/
      ProxyPassReverse / https://production.deepblue-documents.lib.umich.edu:8443/
    | EOT
  }
}
