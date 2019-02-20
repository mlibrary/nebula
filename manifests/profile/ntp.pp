# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::ntp
#
# Manage ntp settings.
#
# @param servers List of ntp servers to use
#
# @example
#   include nebula::profile::ntp
class nebula::profile::ntp (
  Array[String] $servers,
) {

  class { 'ntp':
    servers       => $servers,
    # debian default
    restrict      => [
      '-4 default kod notrap nomodify nopeer noquery limited',
      '-6 default kod notrap nomodify nopeer noquery limited',
      '127.0.0.1',
      '::1',
      'source notrap nomodify noquery'
    ],
    # enabled by default on debian, but we do not use it
    iburst_enable => false
  }

  # not installed by ntp class
  package { 'ntpstat': }
}
