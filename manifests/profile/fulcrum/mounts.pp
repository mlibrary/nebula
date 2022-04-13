# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::mounts

class nebula::profile::fulcrum::mounts (
  Hash $config = {},
) {
  create_resources('nebula::nfs_mount', $config)
}
