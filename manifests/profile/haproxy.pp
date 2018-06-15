# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# haproxy
#
# @example
#   include nebula::profile::haproxy
class nebula::profile::haproxy(String $floating_ip) {
  service { 'haproxy':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/haproxy/haproxy.cfg':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/haproxy.cfg.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  $nodes_for_role = nodes_for_role('nebula::role::webhost::www_lib')
  $nodes_for_datacenter = nodes_for_datacenter($::datacenter)
  $datacenter = $::datacenter

  file { '/etc/haproxy/backends.cfg':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/backends.cfg.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  file { '/etc/haproxy/frontends.cfg':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/frontends.cfg.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  package { 'haproxy': }
  package { 'haproxyctl': }
}
