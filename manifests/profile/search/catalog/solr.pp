# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::search::catalog::solr (
  String $serve_bin = '/opt/catalog/serve/bin/solr',
  Integer $serve_port = 8983,
  String $serve_max_heap_size = '1g',
  String $reindex_bin = '/opt/catalog/reindex/bin/solr',
  Integer $reindex_port = 8984,
  String $reindex_max_heap_size = '1g',
) {
  file { '/l':
    ensure => 'directory',
  }

  file { '/l/solr-vufind':
    ensure  => 'link',
    target  => '/var/lib/vufind',
    require => File['/l'],
  }

  service { 'solr-catalog-serve':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/systemd/system/solr-catalog-serve.service'],
  }

  file { '/etc/systemd/system/solr-catalog-serve.service':
    content => template('nebula/profile/search_solr/catalog-serve-solr.service.erb'),
    notify  => Exec['catalog serve solr reload systemd'],
  }

  file { '/etc/systemd/system/solr-catalog-reindex.service':
    content => template('nebula/profile/search_solr/catalog-reindex-solr.service.erb'),
    notify  => Exec['catalog reindex solr reload systemd'],
  }

  exec { 'catalog serve solr reload systemd':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service['solr-catalog-serve'],
  }

  exec { 'catalog reindex solr reload systemd':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
