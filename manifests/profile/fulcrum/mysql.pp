# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::mysql

class nebula::profile::fulcrum::mysql (
  String $fedora_password,
  String $fulcrum_password,
  String $checkpoint_password,
  String $shibd_password,
  String $password,
) {

  # Install and configure mysql server
  ensure_packages(['mysql', 'mysql-client'])
#  exec { 'secure_mysql':
#    command => "
#mysql -sfu root <<EOS
#-- set root password
#UPDATE mysql.user SET Password=PASSWORD({$password}) WHERE User='root';
#-- delete anonymous users
#DELETE FROM mysql.user WHERE User='';
#-- delete remote root capabilities
#DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
#-- drop database 'test'
#DROP DATABASE IF EXISTS test;
#-- also make sure there are lingering permissions to it
#DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
#-- make changes immediately
#FLUSH PRIVILEGES;
#EOS"
#  }

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
