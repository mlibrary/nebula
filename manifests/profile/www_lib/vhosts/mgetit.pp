# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::mgetit
#
# mgetit virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::mgetit
class nebula::profile::www_lib::vhosts::mgetit (
  String $prefix,
  String $domain,
  String $ssl_cn = 'www.lib.umich.edu',
  String $docroot = '/www/mgetit/current/public'
) {
  $servername = "${prefix}mgetit.${domain}"

  file { "${apache::params::logroot}/mgetit":
    ensure => 'directory',
  }

  nebula::apache::www_lib_vhost { 'mgetit-http':
    servername     => $servername,
    docroot        => false,
    logging_prefix => 'mgetit/',
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

  nebula::apache::www_lib_vhost { 'mgetit-https':
    servername                  => $servername,
    docroot                     => $docroot,
    logging_prefix              => 'mgetit/',

    ssl                         => true,
    ssl_cn                      => $ssl_cn,
    cosign                      => false,
    usertrack                   => true,

    setenv                      => ['HTTPS on'],

    rewrites                    => [
      {
        comment      => 'Serve static assets through apache',
        rewrite_cond => ['/www/mgetit/current/public/$1/index.html -f [OR]', '/www/mgetit/current/public/$1 -f'],
        rewrite_rule => '^/(.*)$  /www/mgetit/current/public/$1 [L]',
      },
      {
        comment      => 'Reverse proxy application to app hostname and port',
        rewrite_rule => '^(/.*)$ http://app-mgetit:30100$1 [P]',
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
    ],

    request_headers             => [
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
      ProxyPassReverse / http://app-mgetit:30100/
    | EOT
  }
}
