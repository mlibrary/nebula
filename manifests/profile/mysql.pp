# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::mysql
#
# @param datadir Path to actual mysql data, replaces dist datadir with a symlink to this path
class nebula::profile::mysql (
  Optional[String] $datadir = undef
) {

  # may need to be parameterized to support non-debian OSes
  if($datadir) {
    file { '/var/lib/mysql': # debian packaged mysql datadir
      ensure => 'link',
      target => $datadir,
      before => Class['mysql::server'],
    }
  }

  # Install and configure mysql server
  class { 'mysql::server':
    create_root_user        => true,
    remove_default_accounts => true,
  }

  # Install the mysql client
  class { 'mysql::client':
    bindings_enable => false
  }

}
