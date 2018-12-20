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
  Array[String] $smartconnect_mounts = ['/htapps'],
  Hash $other_nfs_mounts = {},
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

  $smartconnect_mounts.each |$mount| {
    nebula::nfs_mount { $mount:
      remote_target   => "nas-${::datacenter}.sc:/ifs${mount}",
      tag             => 'smartconnect',
      private_network => true,
      monitored       => true
    }
  }

  create_resources(nebula::nfs_mount,$other_nfs_mounts)

  if($readonly) {
    $sdr_options = 'auto,hard,nfsvers=3,ro'
  } else {
    $sdr_options = 'auto,hard,nfsvers=3'
  }

  Integer[1, 24].each |$partition| {
    nebula::nfs_mount { "/sdr${partition}":
      options       => $sdr_options,
      remote_target => "nas-${::datacenter}.sc:/ifs/sdr/${partition}",
      tag           => 'smartconnect',
      monitored     => true
    }
  }
}
