# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# keepalived
#
# @example
#   include nebula::profile::authzd_user()
define nebula::authzd_user(
  String $home,
  Hash $key,
  String $gid) {

  user { $title:
    gid        => $gid,
    home       => $home,
    managehome => true,
    shell      => '/bin/bash'
  }

  nebula::file::ssh_keys { "${home}/.ssh/authorized_keys":
    keys   => [ $key],
    secret => true,
    owner  => $title,
    group  => $gid
  }
}
