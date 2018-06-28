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

  $key_file = "${home}/.ssh/authorized_keys"

  file { $home:
    ensure => 'directory',
    mode   => '0755'
  }

  user { $title:
    gid     => $gid,
    home    => $home,
    require => File[$home]
  }

  nebula::file::ssh_keys { $key_file:
    keys   => [ $key],
    secret => true,
  }
}
