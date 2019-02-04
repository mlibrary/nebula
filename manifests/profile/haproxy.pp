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
) {
  include nebula::profile::haproxy::prereqs
  include nebula::profile::networking::sysctl

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

  $services.each |$service, $params| {
    @nebula::haproxy::service { $service :
      cert_source => $cert_source,
      *           => $params
    }
  }

  Nebula::Haproxy::Binding <<| datacenter == $::datacenter |>>

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
    notify  => [Service['keepalived'], Service['procps']],
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

}
