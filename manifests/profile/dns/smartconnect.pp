# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::dns::smartconnect
#
# Set up bind9 for smartconnect. You must also define these two array
# parameters in hiera:
#
# - nebula::resolv_conf::searchpath
# - nebula::resolv_conf::nameservers
#
# @param domain Domain to forward to the nameserver
# @param nameserver Nameserver IP address
# @param master_zones Ordered list of master zone names and files
# @param other_ns_ips Override nebula::resolv_conf::nameservers by
#   setting this to a nonempty array of IP addresses
#
# @example
#   include nebula::profile::dns::smartconnect
class nebula::profile::dns::smartconnect (
  String $domain,
  String $nameserver,
  Array  $master_zones,
  Array  $other_ns_ips = [],
) {
  include stdlib

  package { 'nebula::profile::dns::smartconnect::bind9':
    ensure => 'present',
    name   => 'bind9',
  }

  service { 'bind9':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  if empty($other_ns_ips) {
    $nameservers = lookup('nebula::resolv_conf::nameservers')
  } else {
    $nameservers = $other_ns_ips
  }

  class { 'resolv_conf':
    nameservers => concat(['127.0.0.1'], $nameservers),
    searchpath  => lookup('nebula::resolv_conf::searchpath'),
  }

  file { '/etc/bind/named.conf':
    notify  => Service['bind9'],
    content => template('nebula/profile/dns/smartconnect/named.conf.erb'),
  }

  file { '/etc/bind/named.conf.local':
    notify  => Service['bind9'],
    content => template('nebula/profile/dns/smartconnect/named.conf.local.erb'),
  }

  file { '/etc/bind/named.conf.options':
    notify  => Service['bind9'],
    content => template('nebula/profile/dns/smartconnect/named.conf.options.erb'),
  }
}
