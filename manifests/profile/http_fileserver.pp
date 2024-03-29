# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::http_fileserver
#
# Configure Apache to serve a single directory of static files
#
# @example
#   include nebula::profile::http_fileserver

class nebula::profile::http_fileserver (
  String $storage_path,
  String $docroot = '/srv/www',
) {

  package { 'nfs-common': }

  file { $docroot:
    ensure => 'directory',
  }

  file { "/var/local/http":
    ensure => 'directory',
  }

  mount { $docroot:
    ensure  => 'mounted',
    device  => $storage_path,
    fstype  => 'nfs',
    options => 'auto,hard,noacl,nfsvers=3',
    require => ['Package[nfs-common]']
  }

  $letsencrypt_directory = $::letsencrypt_directory[$::fqdn]
  if $letsencrypt_directory {
    class { 'apache':
      docroot           => '/srv/www',
      default_mods      => false,
      default_ssl_cert  => "${letsencrypt_directory}/fullchain.pem",
      default_ssl_key   => "${letsencrypt_directory}/privkey.pem",
      default_vhost     => false,
      default_ssl_vhost => true,
      conf_enabled      => '/etc/apache2/conf-enabled',
    }
  } else {
    class { 'apache':
      docroot           => '/srv/www',
      default_mods      => false,
      default_vhost     => false,
      default_ssl_vhost => false,
      conf_enabled      => '/etc/apache2/conf-enabled',
    }
  }

  apache::vhost { "${::fqdn} http":
    servername => $::fqdn,
    port       => 80,
    docroot    => "/var/local/http",
    require    => File["/var/local/http"]
  }

  nebula::cert { $::fqdn:
    webroot => "/var/local/http",
    require => Apache::Vhost["${::fqdn} http"]
  }

  include nebula::profile::networking::firewall::http_datacenters

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
