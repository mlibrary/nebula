# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::babel_logs
#
# Configure a log directory and Grafana Alloy for shipping logs from babel
# applications to loki
#
# @example
#   include nebula::profile::hathitrust::babel_logs
class nebula::profile::hathitrust::babel_logs (
  String $log_path = '/var/log/babel',
  String $log_owner = 'nobody',
  String $log_group = 'nogroup',
) {

  file { $log_path:
    ensure => 'directory',
    owner  => $log_owner,
    group  => $log_group,
    mode   => '0644'
  }

  file { '/etc/alloy/babel.alloy':
    ensure  => 'file',
    content => template('nebula/profile/hathitrust/babel_logs/alloy.erb'),
  }

  file { '/etc/logrotate.d/babel':
    ensure  => 'file',
    content => template('nebula/profile/hathitrust/babel_logs/logrotate.erb'),
  }
}
