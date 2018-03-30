# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::ntp
#
# Manage ntp settings
#
# @example
#   include nebula::profile::base::ntp
class nebula::profile::base::ntp (
  Array[String] $servers,
) {
  service { 'ntp':
    ensure  => 'running',
    enable  => true,
    require => Package['ntp', 'ntpstat'],
  }

  package { 'ntp': }
  package { 'ntpstat': }

  file_line { 'no debian ntp servers':
    ensure            => 'absent',
    path              => '/etc/ntp.conf',
    match             => '(server|pool).*debian.pool',
    match_for_absence => true,
    multiple          => true,
    notify            => Service['ntp'],
  }

  $servers.each |$server| {
    file_line { "ntp server ${server}":
      path   => '/etc/ntp.conf',
      line   => "server ${server}",
      after  => '^#?server',
      notify => Service['ntp'],
    }
  }
}
