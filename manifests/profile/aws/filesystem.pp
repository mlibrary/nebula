# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::aws::filesystem
#
# Mount persistent EC2 volume if it exists
#
# @example
#   include nebula::profile::aws::filesystem
class nebula::profile::aws::filesystem {

  unless $facts['mountpoints']['/l'] {
    filesystem { '/dev/xvdb':
      ensure  => present,
      fs_type => 'ext4',
    }

    file { '/l':
      ensure  => 'directory',
      path    => '/l',
      mode    => '0755',
      recurse => false
    }

    mount { '/l':
      ensure => 'mounted',
      name   => '/l',
      device => '/dev/xvdb',
      fstype => 'ext4'
    }
  }

}
