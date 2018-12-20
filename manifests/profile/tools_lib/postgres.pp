# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::postgres
#
# Configure postgres for tools.lib
#
# @example
#   include nebula::profile::tools_lib::postgres

class nebula::profile::tools_lib::postgres {
  class { 'postgresql::server':
  }

  postgresql::server::db {
    'jira':
      user     => 'jira',
      password => postgresql_password('jira', lookup('nebula::profile::tools_lib::mysql::jira::password')),
    ;
    'confluence':
      user     => 'confluence',
      password => postgresql_password('confluence', lookup('nebula::profile::tools_lib::mysql::confluence::password')),
  }
}
