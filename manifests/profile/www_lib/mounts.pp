# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::mounts
#
# Mount storage for www_lib
#
# @example
#   include nebula::profile::www_lib::mounts
class nebula::profile::www_lib::mounts (
  String $prod_target,
  String $dev_target,
  Hash $nfs_mounts = {},
  Hash $cifs_mounts = {},
  Hash $cifs_defaults = {}
) {
  create_resources(nebula::nfs_mount,$nfs_mounts)
  create_resources(nebula::cifs_mount,$cifs_mounts,$cifs_defaults)

  nebula::nfs_mount { "/www":
    remote_target   => $prod_target,
    monitored       => true,
    # may not always be true, but doesn't hurt to wait until the private
    # network is up to mount
    private_network => true
  }

  nebula::nfs_mount { "/www-dev":
    remote_target   => $dev_target,
    monitored       => false,
    # may not always be true, but doesn't hurt to wait until the private
    # network is up to mount
    private_network => true
  }
}

