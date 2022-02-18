# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::alma_integrations (
  Array[Hash] $ssh_keys = []
) {

  user { 'alma':
    home => '/var/lib/alma'
  }

  nebula::file::ssh_keys { '/var/lib/alma/.ssh/authorized_keys':
    keys   => $ssh_keys,
    secret => true,
    owner  => 'alma',
    group  => 'alma',
  }
}
