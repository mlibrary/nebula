# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::solr

class nebula::profile::fulcrum::solr {
  include nebula::profile::solr

  file { '/home/fulcrum/solr':
    ensure => directory,
    owner  => 'fulcrum',
    group  => 'fulcrum',
  }

  file { '/home/fulcrum/solr/conf':
    ensure => symlink,
    target => '/home/fulcrum/app/current/solr/config',
    owner  => 'fulcrum',
    group  => 'fulcrum',
  }

  file { '/var/local/fulcrum/solrdata':
    ensure  => directory,
  }

}
