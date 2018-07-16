# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# keepalived
#
# @example
#   include nebula::profile::haproxy::keepalived
class nebula::profile::haproxy::keepalived(Hash $services,
    Boolean $master = false) {
  class { 'nebula::profile::haproxy':
    services => $services,
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
    notify  => Service['keepalived'],
    mode    => '0644',
    content => template('nebula/profile/haproxy/keepalived/sysctl.conf.erb'),
  }
}
