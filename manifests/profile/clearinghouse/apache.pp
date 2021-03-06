
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::clearinghouse
#
# Configure apache & virtual hosts for clearinghouse
#
# AWS host with apache, mysql, php
#
# @example
#   include nebula::role::app_host::standalone
class nebula::profile::clearinghouse::apache (
  String $base_domain = 'clearinghouse.net',
  String $ch_root = '/clearinghouse/web'
) {
  include nebula::profile::named_instances::apache

  $ssl_cn = Class['nebula::profile::named_instances::apache']['ssl_cn']

  include nebula::profile::php73
  include apache::mod::alias

  class { 'apache::mod::dir':
    indexes => ['index.html','index.php']
  }
  class { 'apache::mod::proxy_fcgi': }

  $public_common = {
    servername    => "www.${base_domain}",
    docroot       => "${ch_root}/chPublic/public_html",
    serveraliases => [$base_domain]
  }

  $admin_common = {
    servername => "chadmin.${base_domain}",
    docroot    => "${ch_root}/chAdmin/public_html"
  }

  $nocache_pdf = {
    rewrite_rule => '^/chDocs/(.*[.]pdf)$	/chDocs/no_cache.php?file_path=$1	[passthrough]'
  }

  file { '/etc/apache2/conf-enabled/charset.conf':
    ensure => 'link',
    target => '../conf-available/charset.conf',
  }

  file { '/etc/apache2/conf-enabled/localized-error-pages.conf':
    ensure => 'link',
    target => '../conf-available/localized-error-pages.conf',
  }

  file { '/etc/apache2/conf-enabled/other-vhosts-access-log.conf':
    ensure => 'link',
    target => '../conf-available/other-vhosts-access-log.conf',
  }

  file { '/etc/apache2/conf-enabled/php7.3-fpm.conf':
    ensure => 'link',
    target => '../conf-available/php7.3-fpm.conf',
  }

  file { '/etc/apache2/conf-enabled/security.conf':
    ensure => 'link',
    target => '../conf-available/security.conf',
  }

  file { '/etc/apache2/conf-enabled/serve-cgi-bin.conf':
    ensure => 'link',
    target => '../conf-available/serve-cgi-bin.conf',
  }

  $ssl_params     = {
    ssl            => true,
    ssl_protocol   => 'all -SSLv2 -SSLv3',
    ssl_cipher     => 'EECDH:EDH+aRSA:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS',
    ssl_cert       => "/etc/ssl/certs/${ssl_cn}.crt",
    ssl_key        => "/etc/ssl/private/${ssl_cn}.key",
    ssl_certs_dir  => '/etc/ssl/chain'
  }

  $aliases_common = {
    alias => '/chDocs/',
    path  => "${ch_root}/chDocs/"
  }

  apache::vhost {
    default:
      port           => '80',
      manage_docroot => false,
      rewrites       => [{
        rewrite_rule => ['^(.*)$ https://%{HTTP_HOST}$1 [L,NE,R]']
      }];

    'public-http':
      * => $public_common;

    'admin-http':
      * => $admin_common;
  }

  apache::vhost {
    'public-https':
      port           => '443',
      manage_docroot => false,
      aliases        => [$aliases_common],
      rewrites       => [
        $nocache_pdf,
        {
          # block SQL injection attempts
          rewrite_cond => '%{QUERY_STRING}   (select|insert|update|delete)   [nocase]',
          rewrite_rule => '(.*)      -         [forbidden,last]'
        },
        {
          rewrite_rule => '^/policy$ https://www.law.umich.edu/special/policyclearinghouse/Pages/default.aspx [redirect=permanent,nocase]'
        },
        {
          rewrite_rule => '^/schoolhouse$ https://schoolhouse.clearinghouse.net [redirect=permanent,nocase]'
        },
      ],

      *              => $public_common.merge($ssl_params)
  }

  apache::vhost {
    'admin-https':
      port           => '443',
      manage_docroot => false,
      aliases        => [$aliases_common],
      rewrites       => [$nocache_pdf],

      *              => $admin_common.merge($ssl_params)
  }

}
