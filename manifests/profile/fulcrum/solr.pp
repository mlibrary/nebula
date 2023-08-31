# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::solr

class nebula::profile::fulcrum::solr {
  class { 'nebula::profile::solr':
    base => '/var/lib/solr',
    home => '/var/lib/solr/data',
    logs => '/var/log/solr',
  }

  file {
    ['/opt/solr', '/opt/solr/bin']:
      ensure => 'directory',
    ;
  }

  file {
    ['/var/lib/solr/data/cores']:
      ensure => 'directory',
      owner  => 'solr',
      group  => 'solr',
    ;
  }
}
