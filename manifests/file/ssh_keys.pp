# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::file::ssh_keys
#
# Create a list of SSH keys.
#
# @example
#   nebula::file::ssh_keys { 'namevar': }
define nebula::file::ssh_keys(
  Array   $keys = [],
  Boolean $secret = false,
) {
  if $secret {
    file { dirname($title):
      ensure => 'directory',
      mode   => '0700',
    }
  }

  file { $title:
    content => template('nebula/file/ssh_keys.erb'),
  }
}
