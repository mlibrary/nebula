# Copyright (c) 2018,2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Ingest and indexing servers for hathitrust.org
#
# @example
#   include nebula::role::hathitrust::ingest_indexing
class nebula::role::hathitrust::ingest_indexing (
  String $dataden_target,
  String $private_address_template = '192.168.0.%s'
) {
  include nebula::role::hathitrust

  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }

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
    smartconnect_mounts => ['/htapps','/htprep','/htsolr/lss','/htsolr/lss-reindex'],
    readonly            => false,
    other_nfs_mounts    => {
      '/htdataden' => {
        'remote_target'   => $dataden_target,
        'options'         => 'auto,hard,nfsvers=3',
        'private_network' => false
      }
    }
  }

  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl
  include nebula::profile::hathitrust::clamav
  include nebula::profile::hathitrust::ingest_service

  include nebula::profile::ruby

  nebula::usergroup { 'htingest': }
}
