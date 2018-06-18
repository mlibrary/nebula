# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# keepalived
#
# @example
#   include nebula::profile::keepalived
class nebula::profile::keepalived(String $floating_ip) {
#  require nebula::profile::haproxy
  package { 'keepalived': }
  package { 'ipset': }

  service { 'keepalived':
    ensure => 'running',
    enable => true,
    hasrestart => true,
#    require => Package['keepalived','haproxyctl'],
    require => Package['keepalived'],
  }

  $nodes_for_role = nodes_for_role($title)
  $nodes_for_datacenter = nodes_for_datacenter($::datacenter)
  $email = lookup('nebula::root_email')
  $datacenter = $::datacenter

  file { '/etc/keepalived/keepalived.conf':
    ensure => 'present',
    require => Package['keepalived'],
    notify => Service['keepalived'],
    mode => '0644',
    content => template('nebula/profile/keepalived/keepalived.conf.erb'),
  }

  file { '/etc/sysctl.d/keepalived.conf':
    ensure  => 'present',
    require => Package['keepalived'],
    notify => Service['keepalived'],
    mode    => '0644',
    content => template('nebula/profile/keepalived/sysctl.conf.erb'),
  }
}
