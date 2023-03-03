# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::mysql
#
# @param password The root password, as stored by root's .my.cnf.
class nebula::profile::mysql (
  String $password
) {

  # Install and configure mysql server
  class { 'mysql::server':
    create_root_user        => true,
    create_root_my_cnf      => true,
    root_password           => $password,
    datadir                 => $datapath,
    remove_default_accounts => true,
  }

  # Install the mysql client
  class { 'mysql::client':
    bindings_enable => false
  }

}
