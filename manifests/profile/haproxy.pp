# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# haproxy
#
# @example
#   include nebula::profile::haproxy
class nebula::profile::haproxy(String $floating_ip, String $cert_source, Hash $monitoring_user) {
  service { 'haproxy':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  package { 'haproxy': }
  package { 'haproxyctl': }

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

  file { '/etc/default/haproxy':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/default.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  if $cert_source != '' {
    file { '/etc/ssl/private' :
      ensure => 'directory',
      mode   => '0700',
      owner  => 'root',
      group  => 'root'
    }

    file { '/etc/ssl/private/www-lib':
      ensure  => 'directory',
      mode    => '0700',
      owner   => 'haproxy',
      group   => 'haproxy',
      recurse => true,
      purge   => true,
      links   => 'follow',
      notify  => Service['haproxy'],
      source  => "puppet://${cert_source}/www-lib"
    }
  }

  nebula::authzd_user { $monitoring_user['name']:
    gid  => 'haproxy',
    home => $monitoring_user['home'],
    key  => merge($monitoring_user['key'],
        { command => '/usr/sbin/haproxyctl' } )
  }

}
