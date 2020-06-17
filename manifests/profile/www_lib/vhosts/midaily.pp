# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::midaily
#
# Michigan Daily Digital Archives at Bentley Library virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::midaily
class nebula::profile::www_lib::vhosts::midaily (
  String $ssl_cn = 'digital.bentley.umich.edu',
  String $docroot = '/hydra/midaily-production/current/public'
) {
  $servername = 'digital.bentley.umich.edu'

  file { "${apache::params::logroot}/midaily":
    ensure => 'directory',
  }

  nebula::apache::www_lib_vhost { 'midaily-http':
    servername     => $servername,
    docroot        => $docroot,
    logging_prefix => 'midaily/',
    usertrack      => true,

    rewrites       => [
      {
        rewrite_rule => '^(.*)$ https://%{HTTP_HOST}$1 [L,R,NE]'
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

  nebula::apache::www_lib_vhost { 'midaily-https':
    servername                  => $servername,
    docroot                     => $docroot,
    logging_prefix              => 'midaily/',

    ssl                         => true,
    ssl_cn                      => $ssl_cn,
    cosign                      => true,
    usertrack                   => true,

    setenv                      => ['HTTPS on'],

    rewrites                    => [
      {
        comment      => 'Serve static assets through apache',
        rewrite_cond => '/hydra/midaily-production/current/public/$1 -f',
        rewrite_rule => '^/(.*)$ /hydra/midaily-production/current/public/$1 [L]',
      },
      {
        comment      => 'Reverse proxy application to app hostname and port',
        rewrite_cond => '%{REQUEST_URI} !^/cosign/valid',
        rewrite_rule => '^(/.*)$ http://app-midaily-production:30500$1 [P]',
      },
    ],

    directories                 => [
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
      {
        provider        => 'location',
        path            => '/login',
        auth_type       => 'cosign',
        auth_require    => 'valid-user',
        custom_fragment => 'CosignAllowPublicAccess Off',
      },
    ],

    request_headers             => [
      # Set remote user header to allow app to use http header auth.
      # Setting remote user for 2.4
      'set X-Remote-User "expr=%{REMOTE_USER}"',
      # Fix redirects being sent to non ssl url (https -> http)
      'set X-Forwarded-Proto "https"',
      # Remove existing X-Forwarded-For headers; mod_proxy will automatically add the correct one.
      'unset X-Forwarded-For',
    ],

    headers                     => [
      'set "Strict-Transport-Security" "max-age=3600"',
    ],

    ssl_proxyengine             => true,
    ssl_proxy_check_peer_name   => 'on',
    ssl_proxy_check_peer_expire => 'on',

    custom_fragment             => @(EOT)
      # Reverse proxy application to app hostname and port
      ProxyPassReverse / http://app-midaily-production:30500/
    | EOT
  }
}
