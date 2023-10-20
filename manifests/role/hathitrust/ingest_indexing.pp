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
  include nebula::profile::hathitrust::slip

  file { '/home/libadm':
    ensure => 'directory',
    owner  => 'libadm',
    group  => 'htprod'
  }

  file { '/htsolr':
    ensure => 'directory'
  }

  class { 'nebula::profile::hathitrust::mounts':
    smartconnect_mounts => ['/htapps','/htprep','/htsolr/lss','/htsolr/lss-reindex'],
    readonly            => false,
  }

  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl

  include nebula::profile::ruby

  nebula::usergroup { 'htingest': }
}
