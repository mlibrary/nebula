# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::mounts

class nebula::profile::fulcrum::mounts (
  Hash $config = {},
  Hash $cifs_config = {},
  Hash $symlinks = {},
) {
  create_resources('nebula::nfs_mount', $config)
  create_resources('nebula::cifs_mount', $cifs_config)

  $symlinks.each |$link, $target| {
    file { $link:
      ensure => 'link',
      target => $target,
    }
  }
}
