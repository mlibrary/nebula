# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Packages required for any haproxy services. These are here so the
# requirements in the haproxy service defined type are guaranteed to exist.
#
# @example
#   include nebula::profile::haproxy::prereqs
class nebula::profile::haproxy::prereqs {
  package { 'haproxy':
    ensure => 'installed',
  }

  package { 'socat':
    ensure => 'installed',
  }

  service { 'haproxy':
    ensure  => 'running',
    enable  => true,
    restart => '/bin/systemctl reload haproxy',
  }

  file { '/etc/haproxy':
    ensure => 'directory'
  }

  file { '/etc/haproxy/services.d':
    ensure => 'directory'
  }

  file { '/usr/local/bin/haproxyctl':
    ensure  => 'file',
    require => Package['socat'],
    mode    => '0744',
    content => template('nebula/profile/haproxy/haproxyctl.sh.erb'),
  }

  exec { 'check haproxy config':
    command => '/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -c -q -f /etc/haproxy/services.d',
  }
}
