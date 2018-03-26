# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::authorized_keys
#
# Populate a list of keys from nebula::users.
#
# @example
#   include nebula::profile::base::authorized_keys
class nebula::profile::base::authorized_keys {
  $keys = nebula::get_keys_from_users(
    'nebula::users::sudoers',
    lookup('nebula::users::default_host'))

  nebula::file::ssh_keys { lookup('nebula::users::key_file'):
    keys   => $keys,
    secret => true,
  }
}
