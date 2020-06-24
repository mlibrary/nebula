# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache
#
# Install apache with reasonable defaults for LIT
#
# @example
#   include nebula::profile::apache
class nebula::profile::apache (
  String $chain_crt = 'incommon_sha2.crt',
  String $ssl_cert_dir = '/etc/ssl/certs',
  String $ssl_key_dir = '/etc/ssl/private',
  Optional[Hash] $log_formats = undef,
) {

  $haproxy_ips = nodes_for_class('nebula::profile::haproxy').map |String $nodename| {
    fact_for($nodename, 'networking')['ip']
  }

  $ssl_chain = "${ssl_cert_dir}/${chain_crt}"

  file { $ssl_chain:
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${chain_crt}"
  }

  class { 'apache':
    default_vhost          => false,
    default_ssl_vhost      => false,
    default_ssl_chain      => $ssl_chain,
    timeout                => 300,
    keepalive_timeout      => 2,
    log_formats            => $log_formats,
    # configured below by explicitly declaring params for apache::mod::prefork class
    mpm_module             => false,
    serveradmin            => 'lit-ae-systems@umich.edu',
    trace_enable           => 'Off',
    root_directory_secured => true,
    scriptalias            => undef,
    docroot                => false,
    default_mods           => false,
    user                   => 'nobody',
    group                  => 'nogroup',
  }

  class { 'apache::mod::prefork':
    startservers           => 10,
    minspareservers        => 5,
    maxspareservers        => 10,
    maxrequestworkers      => 256,
    maxconnectionsperchild => 1000
  }

  class { 'apache::mod::remoteip':
    header    => 'X-Client-IP',
    proxy_ips => $haproxy_ips
  }

  apache::custom_config { 'badrobots':
    source => 'puppet:///apache/badrobots.conf'
  }

  file { '/etc/apache2/conf-enabled':
    ensure  => 'directory',
    recurse => true,
    force   => true,
    purge   => true,
    require => Class['apache'],
  }

  file { '/etc/apache2/conf-available':
    ensure  => 'absent',
    force   => true,
    purge   => true,
    require => Class['apache'],
  }

  file { '/etc/logrotate.d/apache2':
    ensure  => file,
    content => template('nebula/profile/apache/logrotate.d/apache2.erb'),
  }

  apache::listen { ['80','443']: }
}
