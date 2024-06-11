# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# haproxy
#
# @example
#   include nebula::profile::haproxy
class nebula::profile::haproxy(
  Hash $services,
  Hash $monitoring_user,
  Boolean $master = false,
  Optional[String] $cert_source = undef,
  Hash $extra_floating_ips = {},
) {
  include nebula::profile::haproxy::prereqs
  include nebula::profile::networking::sysctl
  class { 'nebula::profile::prometheus::exporter::haproxy':
    master => $master
  }

  file {
    default:
      ensure  => 'present',
      mode    => '0644',
      require => Package['haproxy'],
      notify  => Service['haproxy'],
    ;
    '/etc/haproxy/haproxy.cfg':
      content => template('nebula/profile/haproxy/haproxy.cfg.erb');
    '/etc/default/haproxy':
      content => template('nebula/profile/haproxy/default.erb');
    '/etc/haproxy/errors/hsts400.http':
      source  => 'puppet:///modules/nebula/haproxy/errors/hsts400.http';
  }

  file { '/etc/ssl/private' :
    ensure => 'directory',
    mode   => '0700',
    owner  => 'root',
    group  => 'root'
  }

  $services.filter |$service, $params| {
    'floating_ip' in $params
  }.each |$service, $params| {
    @nebula::haproxy::service { $service :
      cert_source => $cert_source,
      *           => $params
    }
  }

  Nebula::Haproxy::Binding <<| datacenter == $::datacenter |>>

  nebula::authzd_user { $monitoring_user['name']:
    gid     => 'haproxy',
    home    => $monitoring_user['home'],
    key     => $monitoring_user['key'],
    require => [Package['haproxy'], Package['haproxyctl']]
  }

  file { "${monitoring_user['home']}/.ssh/id_ecdsa":
    source => "puppet:///ssh-keys/${monitoring_user['name']}/id_ecdsa",
    mode   => '0600',
    owner  => $monitoring_user['name'],
    group  => 'haproxy'
  }
  file { "${monitoring_user['home']}/.ssh/id_ecdsa.pub":
    source => "puppet:///ssh-keys/${monitoring_user['name']}/id_ecdsa.pub",
    mode   => '0644',
    owner  => $monitoring_user['name'],
    group  => 'haproxy'
  }
  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/set_weights.rb':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/set_weights.rb"
  }

  package { 'keepalived': }
  package { 'ipset': }

  service { 'keepalived':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['keepalived'],
  }

  $email = lookup('nebula::root_email')

  concat { '/etc/keepalived/keepalived.conf':
    ensure  =>  'present',
    require => Package['keepalived'],
    notify  => Service['keepalived'],
    mode    => '0644',
  }

  concat_fragment { 'keepalived preamble':
    target  => '/etc/keepalived/keepalived.conf',
    content => template('nebula/profile/haproxy/keepalived/keepalived_pre.erb'),
    order   => '01'
  }

  @@concat_fragment { "keepalived node ip ${::hostname}":
    target  => '/etc/keepalived/keepalived.conf',
    content => "    ${::ipaddress}\n",
    tag     => "keepalived-haproxy-ip-${::datacenter}",
    order   => '02'
  }

  # don't collect our own IP address, just the other haproxy nodes here
  Concat_fragment <<| tag == "keepalived-haproxy-ip-${::datacenter}" and title != "keepalived node ip ${::hostname}" |>>

  concat_fragment { 'keepalived postamble':
    target  => '/etc/keepalived/keepalived.conf',
    content => template('nebula/profile/haproxy/keepalived/keepalived_post.erb'),
    order   => '03'
  }

  file { '/etc/sysctl.d/keepalived.conf':
    ensure  => 'present',
    require => Package['keepalived'],
    notify  => [Service['keepalived'], Service['procps'], Service['haproxy']],
    mode    => '0644',
    content => template('nebula/profile/haproxy/keepalived/sysctl.conf.erb'),
  }

  @@firewall { "200 HTTP: HAProxy ${::hostname}":
    proto  => 'tcp',
    dport  => [80, 443],
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
    tag    => 'haproxy'
  }

  # HAProxy should listen for kubernetes connections.
  nebula::exposed_port { '200 kubectl':
    port  => 6443,
    block => 'umich::networks::all_trusted_machines',
  }

  file { '/etc/haproxy/services.d/stats.cfg':
    require => 'Package[haproxy]',
    notify  => 'Service[haproxy]',
    content => template('nebula/profile/haproxy/stats_frontend.cfg.erb'),
  }

}
