# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::mysql
#
# Configure mysql for tools.lib
#
# @example
#   include nebula::profile::tools_lib::mysql

class nebula::profile::tools_lib::mysql {
  class { '::mysql::server':
  }

  mysql::db {
    'jira':
      user     => 'jira',
      password => lookup('nebula::profile::tools_lib::mysql::jira::password'),
      host     => 'localhost',
      grant    => ['ALL'];
    'confluence':
      user     => 'confluence',
      password => lookup('nebula::profile::tools_lib::mysql::confluence::password'),
      host     => 'localhost',
      grant    => ['ALL']
  }
}
