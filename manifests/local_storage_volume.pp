# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::local_storage_volume
# 
# Create a volume to use for kubernetes local storage on a worker node
##
# @param name The name of the volume
# @param capacity The disk capacity in MB

define nebula::local_storage_volume (
  String $name,
  Integer $mib_capacity
) {

  file { "/mnt/local-pvs/mounts/$name":
    ensure => 'directory'
  }

  exec { "make disk file":
    command => "dd if=/dev/zero of=/mnt/local-pvs/disks/${name} bs=1048576 count=${mib_capacity}",
    creates => "/mnt/local-pvs/disks/${name}"
  }

  exec { "make it a filesystem":
    command => "mkfs.ext4 -m 0 /mnt/local-pvs/disks/${name}",
    unless => "file /mnt/local-pvs/disks/${name} | grep ext4"
  }

  mount { "/mnt/local-pvs/mounts/${name}":
    ensure  => 'mounted',
    device  => "/mnt/local-pvs/disks/${name}",
    options => "loop,rw,usrquote,grpquota",
    fstype  => 'ext4',
  }
}
