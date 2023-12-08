# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::symlinks

class nebula::profile::fulcrum::symlinks (
  Hash $config = {},
) {
  $config.each |$link, $target| {
    file { $link:
      ensure => 'link',
      target => $target,
    }
  }
}
