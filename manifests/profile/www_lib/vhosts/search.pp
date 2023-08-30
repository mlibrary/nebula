# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::vhosts::search
#
# search virtual host
#
# @example
#   include nebula::profile::www_lib::vhosts::search
class nebula::profile::www_lib::vhosts::search (
  String $prefix,
  String $domain,
  String $ssl_cn = 'search.lib.umich.edu',
  String $docroot = '/www/search/current/public'
) {
  $servername = "${prefix}search.${domain}"

  file { "${apache::params::logroot}/search":
    ensure => 'directory',
  }

  nebula::apache::www_lib_vhost { 'search-http':
    servername     => $servername,
    docroot        => false,
    logging_prefix => 'search/',
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

  nebula::apache::www_lib_vhost { 'search-https':
    servername                  => $servername,
    docroot                     => $docroot,
    logging_prefix              => 'search/',

    ssl                         => true,
    ssl_cn                      => $ssl_cn,
    usertrack                   => true,

    rewrites                    => [
      {
        comment      => 'Bentley Historical Library',
        rewrite_cond => '%{QUERY_STRING} inst=bentley',
        rewrite_rule => '^/?$  https://search.lib.umich.edu/catalog?library=Bentley+Historical+Library [last,redirect]',
      },
      {
        comment      => 'William L. Clements Library',
        rewrite_cond => '%{QUERY_STRING} inst=clements',
        rewrite_rule => '^/?$  https://search.lib.umich.edu/catalog?library=William+L.+Clements+Library [last,redirect]',
      },
      {
        comment      => 'Flint Thompson Library',
        rewrite_cond => '%{QUERY_STRING} inst=flint',
        rewrite_rule => '^/?$  https://search.lib.umich.edu/catalog?library=Flint+Thompson+Library [last,redirect]',
      },
      {
        comment      => 'U-M Ann Arbor Libraries',
        rewrite_cond => '%{QUERY_STRING} inst=aa',
        rewrite_rule => '^/?$  https://search.lib.umich.edu/catalog?library=U-M+Ann+Arbor+Libraries [last,redirect]',
      },
      {
        comment      => 'Serve static assets through apache',
        rewrite_cond => ['/www/search/current/public/$1 -d [OR]', '/www/search/current/public/$1 -f'],
        rewrite_rule => '^/(.*)$  /www/search/current/public/$1 [L]',
      },
      {
        comment      => 'Reverse proxy application to app hostname and port',
        rewrite_rule => '^(/.*)$ http://app-search:30101$1 [P]',
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
      ProxyPassReverse / http://app-search:30101/
    | EOT
  }
}
