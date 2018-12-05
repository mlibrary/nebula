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
  String $docroot = '/srv/www'
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
    default_ssl_chain => '/etc/ssl/certs/incommon_sha2.crt',
    default_ssl_cert  => "/etc/ssl/certs/${::fqdn}.crt",
    default_ssl_key   => "/etc/ssl/private/${::fqdn}.key",
    default_vhost     => true,
    default_ssl_vhost => true,
  }

  include nebula::profile::networking::firewall::http_datacenters

}
