# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache
#
# Install apache for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::imgsrv
class nebula::profile::hathitrust::imgsrv (
  Integer $num_proc,
  String $sdrroot,
  String $sdrview,
  String $sdrdataroot,
  String $fcgi_ipc_dir = '/tmp/fastcgi'
) {

  file { $fcgi_ipc_dir:
    ensure => 'directory',
    owner  => 'nobody',
    group  => 'nogroup',
    mode   => '0700'
  }

  file { '/usr/local/bin/startup_imgsrv':
    ensure  => 'present',
    content => template('nebula/profile/hathitrust/imgsrv/startup_imgsrv.erb'),
    notify  => Service['imgsrv']
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

}
