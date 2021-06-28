# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::imgsrv
#
# Install imgsrv for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::imgsrv
class nebula::profile::hathitrust::imgsrv (
  String $sdrroot,
  String $sdrview,
  String $sdrdataroot,
  String $bind,
  Integer $num_proc = 10,
  String $log_root = '/var/log',
  String $logging_prefix = 'imgsrv'
) {
  $log_path = "${log_root}/${logging_prefix}"

  file { $log_path:
    ensure => 'directory',
    owner  => 'nobody',
    group  => 'nogroup',
    mode   => '0755'
  }

  logrotate::rule { 'imgsrv':
    path          => [ "${log_path}/imgsrv.out", "${log_path}/imgsrv.err" ],
    rotate        => 7,
    rotate_every  => 'day',
    missingok     => true,
    ifempty       => false,
    delaycompress => true,
    compress      => true,
  }

  file { '/usr/local/bin/startup_imgsrv':
    ensure  => 'present',
    content => template('nebula/profile/hathitrust/imgsrv/startup_imgsrv.erb'),
    notify  => Service['imgsrv'],
    mode    => '0755'
  }

  file { '/etc/systemd/system/imgsrv.service':
    ensure  => 'present',
    content => template('nebula/profile/hathitrust/imgsrv/imgsrv.service.erb'),
    notify  => Service['imgsrv']
  }

  service { 'imgsrv':
    ensure     => 'running',
    enable     => true,
    hasrestart =>  true
  }

  cron { 'imgsrv responsiveness check':
    command => '/usr/local/bin/check_imgsrv > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/2',
  }


  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/check_imgsrv':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/check_imgsrv"
  }

  file { '/usr/local/bin/startup_app':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/startup_app"
  }

}
