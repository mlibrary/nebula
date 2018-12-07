# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::mounts
#
# Mount storage for HathiTrust
#
# $readonly - mount repository read-only (default)
# $ramdisk_size - size of temporary scratch space
#
# @example
#   include nebula::profile::hathitrust::mounts
class nebula::profile::hathitrust::mounts (
  String $ramdisk_size = '4g',
  Boolean $readonly = true
) {
  include nebula::profile::dns::smartconnect;

# TODO - extract somewhere else common when we need ramdisks set up in other
# puppet profiles
  file { '/ram':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root'
  }

  mount { '/ram':
    ensure  => 'mounted',
    name    => '/ram',
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => "size=${ramdisk_size}"
  }

  package { 'nfs-common': }

  file { '/htapps':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root'
  }

  $mount_options = {
    ensure  => 'mounted',
    fstype  => 'nfs',
    require => ['Package[nfs-common]','Service[bind9]'],
    tag     => 'private_network'
  }

  mount { '/htapps':
    name    => '/htapps',
    device  => 'nas-macc.sc:/ifs/htapps',
    options => 'auto,hard',
    *       => $mount_options
  }

  if($readonly) {
    $sdr_options = 'auto,hard,ro'
  } else {
    $sdr_options = 'auto,hard'
  }

  Integer[1, 24].each |$partition| {
    file { "/sdr${partition}":
      ensure => 'directory',
    }

    mount { "/sdr${partition}":
      name    => "/sdr${partition}",
      device  => "nas-macc.sc:/ifs/sdr/${partition}",
      options => $sdr_options,
      *       => $mount_options
    }
  }
}
