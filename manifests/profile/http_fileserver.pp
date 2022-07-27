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
  String $chain_crt = 'incommon_sha2.crt'
) {

  package { 'nfs-common': }

  file { $docroot:
    ensure => 'directory',
  }

  mount { $docroot:
    ensure  => 'mounted',
    device  => $storage_path,
    fstype  => 'nfs',
    options => 'auto,hard,noacl,nfsvers=3',
    require => ['Package[nfs-common]']
  }

  class { 'nebula::profile::ssl_keypair':
    common_name => $::fqdn
  }

  class { 'apache':
    docroot           => '/srv/www',
    default_mods      => false,
    default_ssl_chain => "/etc/ssl/certs/${chain_crt}",
    default_ssl_cert  => "/etc/ssl/certs/${::fqdn}.crt",
    default_ssl_key   => "/etc/ssl/private/${::fqdn}.key",
    default_vhost     => true,
    default_ssl_vhost => true,
    conf_enabled      => '/etc/apache2/conf-enabled',
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
