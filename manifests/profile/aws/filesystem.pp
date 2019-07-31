# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::aws::filesystem
#
# Mount persistent EC2 volume if it exists
#
# @example
#   include nebula::profile::aws::filesystem
class nebula::profile::aws::filesystem (
  String $disk = 'xvdb',
  String $device = '/dev/xvdb',
  String $mountpoint = '/l'
){

  if $facts['disks'][$disk] {
    filesystem { $device:
      ensure  => present,
      fs_type => 'ext4',
    }

    file { $mountpoint:
      ensure  => 'directory',
      path    => $mountpoint,
      mode    => '0755',
      recurse => false
    }

    mount { $mountpoint:
      ensure => 'mounted',
      name   => $mountpoint,
      device => $device,
      fstype => 'ext4'
    }
  }

}
