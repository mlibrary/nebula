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
  Array[String] $mounts = ['/htapps'],
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

  $nfs_mount_options = {
    ensure  => 'mounted',
    fstype  => 'nfs',
    require => ['Package[nfs-common]','File[/etc/resolv.conf]'],
    tag     => 'private_network'
  }

  $mounts.each |$mount| {
    file { $mount:
      ensure => 'directory',
    }

    mount { $mount:
      name    => $mount,
      device  => "nas-macc.sc:/ifs${mount}",
      options => 'auto,hard',
      *       => $nfs_mount_options
    }

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
      *       => $nfs_mount_options
    }
  }
}
