# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::filesystems (
  Hash[String, Hash] $cifs_mounts = {},
  Hash[String, Hash] $local_storage_volumes = {},
) {
  ensure_packages(['nfs-common', 'lvm2'], {'ensure' => 'present'})

  $cifs_mounts.each |$mount_title, $mount_parameters| {
    nebula::cifs_mount { "/mnt/legacy_cifs_${mount_title}":
      * => $mount_parameters,
    }
  }

  $local_storage_volumes.each |$mount_title, $mount_parameters| {
    nebula::local_storage_volume { $mount_title:
      * => $mount_parameters,
    }
  }
}
