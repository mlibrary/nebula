# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::demomysql

class nebula::profile::fulcrum::demomysql (
  String $fedora_password,
  String $fulcrum_password,
  String $checkpoint_password,
  String $shibd_password,
  String $password,
) {

  # Install and configure mysql server
  class { 'mysql::server':
    create_root_user        => true,
    create_root_my_cnf      => true,
    root_password           => $password,
    remove_default_accounts => true,
  }

  $options = {
    'mysqld' => {
      'ssl-disable' => true
    }
  }

  # Install the mysql client
  class { 'mysql::client':
    bindings_enable => false,
  }

  mysql::db { 'fedora':
    user     => 'fedora',
    password => $fedora_password,
    host     => 'localhost',
  }

  mysql::db { 'fulcrum':
    user     => 'fulcrum',
    password => $fulcrum_password,
    host     => 'localhost',
  }

  mysql::db { 'checkpoint':
    user     => 'checkpoint',
    password => $checkpoint_password,
    host     => 'localhost',
  }

  mysql::db { 'shibd':
    user     => 'shibd',
    password => $shibd_password,
    host     => 'localhost',
  }
}
