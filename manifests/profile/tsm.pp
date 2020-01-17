# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tsm
#
# Install TSM backup agent
#
# @param servername The value to use for Servername in dsm.sys, e.g. "mytsm"
#
# @param serveraddress The value to use for TCPServeraddress in dsm.sys, e.g.
# "mytsm.whatever.umich.edu"
#
# @param port The value to use for TCPPort in dsm.sys, for example 1510.
#
# @param encryption Whether to enable encryption. You must configure the
# encryption key manually.
#
# @param $inclexcl An array of lines to add to /etc/adsm/inclexcl, for example
#    exclude.dir /some/path
#    include /some/path/inside/.../*
#
# @param $domains An array of paths to back up, for example "/etc", "/var", etc
#
# @param $virtualmountpoints An array of paths (listed in $domains) that are
# not their own filesystem, but should be backed up as if they are (e.g. if
# "/etc" is not its own filesystem)
#
# @param exclude_dirs Directories never to back up
#
# This does not automate entry of the node password or encryption key (if
# used); "dsmc" must still be run manually to configure that.

class nebula::profile::tsm (
  String $servername,
  String $serveraddress,
  Boolean $encryption = false,
  Integer $port = 1510,
  Array[String] $inclexcl = ['exclude /.../.nfs*', 'exclude.dir /.../.snapshot'],
  Array[String] $domains = ['/etc','/opt','/var'],
  Array[String] $virtualmountpoints = ['/etc','/opt','/var'],
  Array[String] $exclude_dirs = ['/afs/','/net/','/nfs/','/usr/vice/cache/']
) {

  ensure_packages(['tivsm-ba',])
  $tsm_home = '/opt/tivoli/tsm/client/ba/bin'

  file { '/etc/systemd/system/tsm.service':
    source => 'puppet:///modules/nebula/tsm/tsm.service',
  }

  service { 'dsmcad':
    ensure => 'stopped',
    enable => false,
  }

  service { 'tsm':
    enable => true,
  }

  file { '/etc/adsm':
    ensure => 'directory',
  }

  file { '/etc/adsm/inclexcl':
    ensure  => 'file',
    content => $inclexcl.join("\n"),
  }

  file { "${tsm_home}/dsm.opt":
    ensure  => 'file',
    content => template('nebula/profile/tsm/dsm.opt.erb'),
  }

  file { "${tsm_home}/dsm.sys":
    ensure  => 'file',
    content => template('nebula/profile/tsm/dsm.sys.erb'),
  }

}
