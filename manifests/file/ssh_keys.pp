# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::file::ssh_keys
#
# Create a list of SSH keys.
#
# @param keys Keys to add to the file, where each key is a hash
#   containing type, data, and comment values
# @param secret Whether to ensure that the parent directory is 0700
#
# @example A public key file
#   nebula::file::ssh_keys { '/etc/keys':
#     keys => [
#       { type    => 'ssh-rsa',
#         data    => 'AAAAAAAAAAAA',
#         comment => 'user1@host' },
#       { type    => 'ssh-rsa',
#         data    => 'BBBBBBBBBBBB',
#         comment => 'user2@host' },
#     ]
#   }
#
# @example A private key file (/etc/secret will be 0700)
#   nebula::file::ssh_keys { '/etc/secret/keys':
#     secret => true,
#     keys   => [
#       { type    => 'ssh-rsa',
#         data    => 'CCCCCCCCCCCC',
#         comment => 'user3@host' },
#       { type    => 'ssh-rsa',
#         data    => 'DDDDDDDDDDDD',
#         comment => 'user4@host' },
#     ]
#   }
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
