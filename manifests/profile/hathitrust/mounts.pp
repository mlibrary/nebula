# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::mounts
#
# Mount storage for HathiTrust
#
# $ramdisk_size - size of temporary scratch space
# $nas_mounts - list of filesystems to mount from primary ht nas
#
# @example
#   include nebula::profile::hathitrust::mounts
class nebula::profile::hathitrust::mounts (
  String $ramdisk_size = '4g',
  Array[String] $nas_mounts = ['/htapps'],
  Hash $other_nfs_mounts = {},
) {
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

  $nas_mounts.each |$mount| {
    nebula::nfs_mount { $mount:
      options         => 'auto,hard',
      remote_target   => "truenas:/mnt/tank${mount}",
      private_network => true,
      monitored       => true
    }
  }

  create_resources(nebula::nfs_mount,$other_nfs_mounts)

  nebula::nfs_mount { '/sdr':
    options       => 'auto,hard',
    remote_target => 'truenas:/mnt/tank/sdr',
    monitored     => true
  }
  Integer[1, 24].each |$partition| {
    file { "/sdr${partition}":
      ensure => 'link',
      target => "/sdr/${partition}"
    }
  }
}
