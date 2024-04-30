# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::local_storage_volume
# 
# Create a volume to use for kubernetes local storage on a worker node
##
# @param volume_name The (conventionally "${UUID}-pvc") name of the volume
# @param capacity The disk capacity in MB

define nebula::local_storage_volume (
  String $volume_name,
  Integer $mib_capacity
) {

  file { "/mnt/local-pvs/mounts/$volume_name":
    ensure => 'directory'
  }

  exec { "make $volume_name disk file":
    command => "/bin/dd if=/dev/zero of=/mnt/local-pvs/disks/${volume_name} bs=1048576 count=${mib_capacity}",
    creates => "/mnt/local-pvs/disks/${volume_name}"
  }

  exec { "make $volume_name a filesystem":
    command => "/sbin/mkfs.ext4 -m 0 /mnt/local-pvs/disks/${volume_name}",
    unless => "/usr/bin/file /mnt/local-pvs/disks/${volume_name} | grep ext4"
  }

  mount { "/mnt/local-pvs/mounts/${volume_name}":
    ensure  => 'mounted',
    device  => "/mnt/local-pvs/disks/${volume_name}",
    options => "loop,rw,usrquote,grpquota",
    fstype  => 'ext4',
  }
}
