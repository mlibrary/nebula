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
    conf_enabled      => '/etc/apache2/conf-enabled',
  }

  class { 'apache::mod::proxy':
    proxy_requests => 'Off',
    proxy_via      => 'Block',
    proxy_timeout  => 300,
  }

  class { 'apache::mod::dir':
    indexes => ['index.html']
  }

  class { 'apache::mod::rewrite': }

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
        path     => '*',
        require  => 'all granted'
      },
      {
        # CVE-2019-11581
        provider => 'locationmatch',
        path     => 'SendBulkMail',
        require  => 'all denied'
      },
      {
        # CVE-2019-8451
        provider => 'locationmatch',
        path     => '/jira/plugins/servlet/gadgets/makeRequest.*',
        require  => 'all denied'
      },
      {
        # CVE-2019-15003 CVE-2019-15004
        provider => 'locationmatch',
        path     => '/jira/servicedesk/.*\.jsp.*',
        require  => 'all denied'
      },
      {
        # CVE-2019-15003 CVE-2019-15004
        provider => 'locationmatch',
        path     => '/jira/.*\.\..*',
        require  => 'all denied'
      },
      {
        provider => 'location',
        path     => '/synchrony',
        rewrites => [{
          rewrite_cond => ['%{HTTP:UPGRADE} ^WebSocket$ [NC]', '%{HTTP:CONNECTION} Upgrade$ [NC]' ],
          rewrite_rule => ['.* ws://localhost:8091%{REQUEST_URI} [P]']
        }],
      }
    ],

    proxy_pass          => [
      { path => '/confluence', url => 'http://localhost:8090/confluence', keywords => ['nocanon'] },
      { path => '/jira',       url => 'http://localhost:8080/jira',       keywords => ['nocanon'] },
      { path => '/synchrony',  url => 'http://localhost:8091/synchrony',  reverse_urls => []      },
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

  file {
    default:
      ensure => 'link',
    ;

    '/etc/apache2/conf-enabled/charset.conf':
      target => '../conf-available/charset.conf',
    ;

    '/etc/apache2/conf-enabled/localized-error-pages.conf':
      target => '../conf-available/localized-error-pages.conf',
    ;

    '/etc/apache2/conf-enabled/other-vhosts-access-log.conf':
      target => '../conf-available/other-vhosts-access-log.conf',
    ;

    '/etc/apache2/conf-enabled/security.conf':
      target => '../conf-available/security.conf',
    ;

    '/etc/apache2/conf-enabled/serve-cgi-bin.conf':
      target => '../conf-available/serve-cgi-bin.conf',
    ;
  }

}
