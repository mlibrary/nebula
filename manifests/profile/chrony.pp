# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::chrony
#
# Manage ntp settings.
#
# @param servers List of ntp servers to use
#
# @example
#   include nebula::profile::chrony
class nebula::profile::chrony (
  Array[String] $servers = lookup('nebula::profile::ntp::servers'),
) {

  package { 'ntp':
    ensure => 'absent',
  }

  package { 'chrony':
    ensure => 'present',
  }

  service { 'chrony':
    ensure  => 'running',
    enable  => true,
    require => Package['chrony'],
  }

  file_line { 'disable default ntp hosts':
    path              => '/etc/chrony/chrony.conf',
    ensure            => 'absent',
    match             => '^(pool|server).*',
    match_for_absence => true,
    multiple          => true,
    notify            => Service['chrony'],
    require           => Package['chrony'],
  }

  file { '/etc/chrony/sources.d/local-ntp-server.sources':
    ensure  => 'file',
    content => $servers.map |$n| { "server ${n}" }.join("\n"),
    notify  => Service['chrony'],
    require => Package['chrony'],
  }

  if $::is_virtual and $::virtual == 'kvm' {
    kmod::load { 'ptp_kvm': }

    file { '/etc/chrony/conf.d/kvm.conf':
      ensure  => 'file',
      content => 'refclock PHC /dev/ptp_kvm poll 2',
      notify  => Service['chrony'],
    }
  }
}
