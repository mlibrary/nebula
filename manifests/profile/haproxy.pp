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
  String $cert_source = '',
) {
  require nebula::profile::haproxy::prereqs
  require nebula::profile::networking::sysctl

  $balanced_frontends = balanced_frontends()

  file { '/etc/haproxy/haproxy.cfg':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/haproxy.cfg.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  file { '/etc/default/haproxy':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/default.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  file { '/etc/ssl/private' :
    ensure => 'directory',
    mode   => '0700',
    owner  => 'root',
    group  => 'root'
  }

  $balanced_frontends.each |$service, $node_names| {
    nebula::haproxy_service { $service :
      cert_source => $cert_source,
      node_names  => $node_names,
      *           => $services[$service]
    }
  }

  nebula::authzd_user { $monitoring_user['name']:
    gid  => 'haproxy',
    home => $monitoring_user['home'],
    key  => $monitoring_user['key']
  }

  package { 'keepalived': }
  package { 'ipset': }

  service { 'keepalived':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['keepalived'],
  }

  $nodes_for_class = nodes_for_class($title)
  $nodes_for_datacenter = nodes_for_datacenter($::datacenter)
  $email = lookup('nebula::root_email')

  file { '/etc/keepalived/keepalived.conf':
    ensure  => 'present',
    require => Package['keepalived'],
    notify  => Service['keepalived'],
    mode    => '0644',
    content => template('nebula/profile/haproxy/keepalived/keepalived.conf.erb'),
  }

  file { '/etc/sysctl.d/keepalived.conf':
    ensure  => 'present',
    require => Package['keepalived'],
    notify  => [Service['keepalived'], Service['procps']],
    mode    => '0644',
    content => template('nebula/profile/haproxy/keepalived/sysctl.conf.erb'),
  }

}
