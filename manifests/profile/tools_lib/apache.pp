# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::apache
#
# Configure Apache for tools.lib to reverse proxy atlassian suite
# and serve a trivial splash page
#
# @example
#   include nebula::profile::tools_lib::apache

class nebula::profile::tools_lib::apache (
  String $servername,
  String $keyname,
) {

  $docroot = '/srv/www'

  file {
    default:
      ensure => 'directory',
      mode   => '0755',
    ;
    $docroot:
    ;
    "${docroot}/rest":
  }

  $http_files = lookup('nebula::http_files')

  file {
    default:
      ensure => 'present',
      mode   => '0644',
    ;
    "${docroot}/index.html":
      source => "https://${http_files}/tools.lib/index.html"
    ;
    "${docroot}/index.css":
      source => "https://${http_files}/tools.lib/index.css"
    ;
    "${docroot}/mlibrary.png":
      source => "https://${http_files}/tools.lib/mlibrary.png"
    ;
    "${docroot}/rest/index.html":
      source => "https://${http_files}/tools.lib/rest/index.html"
  }

  class { 'nebula::profile::ssl_keypair':
    common_name => $keyname,
  }

  class { 'apache':
    docroot           => $docroot,
    default_mods      => false,
    default_vhost     => false,
    default_ssl_vhost => false,
  }

  class { 'apache::mod::proxy':
    proxy_requests => 'Off',
    proxy_via      => 'Block',
  }

  class { 'apache::mod::dir':
    indexes => ['index.html']
  }

  $chain_crt = lookup('nebula::profile::ssl_keypair::chain_crt')

  apache::vhost { "${servername} ssl":
    servername          => $servername,
    port                => '443',
    docroot             => $docroot,
    access_log_format   => 'combined',
    ssl                 => true,
    ssl_protocol        => '+TLSv1.2',
    ssl_cert            => "/etc/ssl/certs/${keyname}.crt",
    ssl_key             => "/etc/ssl/private/${keyname}.key",
    ssl_chain           => "/etc/ssl/certs/${chain_crt}",

    # from babel-common
    directoryindex      => 'index.html',

    directories         => [
      {
        provider => 'proxy',
        location => '*',
        require  => 'all granted'
      },
      {
        provider => 'location',
        location => '/synchrony',
        rewrites => [{
          rewrite_cond => ['%{HTTP:UPGRADE} ^WebSocket$ [NC]', '%{HTTP:CONNECTION} Upgrade$ [NC]' ],
          rewrite_rule => ['.* ws://localhost:8091%{REQUEST_URI} [P]']
        }],
      }
    ],

    proxy_pass          => [
      { path => '/confluence', url => 'http://localhost:8090/confluence' },
      { path => '/jira',       url => 'http://localhost:8080/jira'       },
      { path => '/synchrony' , url => 'http://localhost:8091/synchrony', reverse_urls => [] },
    ],

    proxy_preserve_host => true,
  }

  apache::vhost { "${servername} non-ssl":
    servername      => $servername,
    docroot         => false,
    port            => '80',
    redirect_source => '/',
    redirect_status => 'permanent',
    redirect_dest   => "https://${servername}/",
  }

  firewall { '200 HTTP':
    proto  => 'tcp',
    dport  => [80, 443],
    state  => 'NEW',
    action => 'accept',
  }

}
