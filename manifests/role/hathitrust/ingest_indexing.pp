# Copyright (c) 2018-2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Ingest and indexing servers for hathitrust.org
#
# @example
#   include nebula::role::hathitrust::ingest_indexing
class nebula::role::hathitrust::ingest_indexing () {
  include nebula::role::hathitrust

  include nebula::profile::hathitrust::networking

  include nebula::profile::hathitrust::ingest_hosts

  file { '/home/libadm':
    ensure => 'directory',
    owner  => 'libadm',
    group  => 'htprod'
  }

  file { '/htsolr':
    ensure => 'directory'
  }

  class { 'nebula::profile::hathitrust::mounts':
    nas_mounts => ['/htapps','/htprep','/htsolr/lss','/htsolr/lss-reindex'],
  }

  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl

  include nebula::profile::ruby

  class { 'nebula::profile::hathitrust::babel_logs':
    log_owner => 'slip',
    log_group => 'htprod'
  }

  nebula::usergroup { 'htingest': }
}
