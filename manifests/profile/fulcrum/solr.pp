# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::solr

class nebula::profile::fulcrum::solr {
  include nebula::profile::solr

  file { '/home/fulcrum/solr':
    ensure => directory,
    owner  => 'solr',
    group  => 'solr',
  }

  file { '/home/fulcrum/solr/conf':
    ensure => symlink,
    target => '/home/fulcrum/app/current/solr/config',
    owner  => 'fulcrum',
    group  => 'fulcrum',
  }

  file { '/var/local/solrdata':
    ensure => directory,
    owner  => 'solr',
    group  => 'solr',
  }

}
