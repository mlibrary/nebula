# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::mysql

class nebula::profile::fulcrum::mysql (
  String $fedora_password,
  String $fulcrum_password,
  String $checkpoint_password,
  String $shibd_password,
) {
  include nebula::profile::mysql

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
