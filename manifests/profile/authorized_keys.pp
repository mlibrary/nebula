# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::authorized_keys
#
# Populate a list of keys from nebula::users.
#
# @example
#   include nebula::profile::authorized_keys
class nebula::profile::authorized_keys (
  String $key_file,
  String $default_host,
  Hash   $ssh_keys,
) {
  Nebula::File::Ssh_keys[$key_file] -> Package<| |>
  nebula::file::ssh_keys { $key_file:
    keys   => nebula::get_keys_from_users($ssh_keys, $default_host),
    secret => true,
  }
}
