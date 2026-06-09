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
  Hash $solr_user = {},
  String $authorized_keys = '',
) {
  file { '/l':
    ensure => 'directory',
  }

  $solr_user_defaults = {
    'comment'    => 'Search Catalog Solr User',
    'name'       => 'search-catalog-solr',
    'group_name' => 'search-catalog-solr',
    'uid'        => 1000,
    'gid'        => 1000,
  }

  $solr_user_name = pick($solr_user['name'], $solr_user_defaults['name'])
  $solr_user_home = pick($solr_user['home'], "/home/${solr_user_name}")
  $solr_group_name = pick($solr_user['group_name'], $solr_user_defaults['group_name'])

  if $facts['os']['distro']['codename'] != 'bullseye' {
    group { $solr_group_name:
      gid => pick($solr_user['gid'], $solr_user_defaults['gid']),
    }

    user { $solr_user_name:
      comment    => pick($solr_user['comment'], $solr_user_defaults['comment']),
      uid        => pick($solr_user['uid'], $solr_user_defaults['uid']),
      gid        => $solr_group_name,
      home       => $solr_user_home,
      shell      => '/bin/bash',
      managehome => true,
      require    => Group[$solr_group_name],
    }

    file { "${solr_user_home}/.ssh":
      ensure  => 'directory',
      mode    => '0700',
      owner   => $solr_user_name,
      group   => $solr_group_name,
      require => User[$solr_user_name],
    }

    file { "${solr_user_home}/.ssh/authorized_keys":
      content => $authorized_keys,
      owner   => $solr_user_name,
      group   => $solr_group_name,
      require => File["${solr_user_home}/.ssh"],
    }

    exec { "${solr_user_home}/.ssh/id_ed25519":
      command => "/usr/bin/ssh-keygen -t ed25519 -N '' -f ${solr_user_home}/.ssh/id_ed25519",
      creates => "${solr_user_home}/.ssh/id_ed25519",
      user    => $solr_user_name,
      require => File["${solr_user_home}/.ssh"],
    }

    file { '/etc/sudoers.d/solr-catalog':
      mode    => '0440',
      content => template('nebula/profile/search_solr/sudoers.erb'),
    }
  }

  file { '/l/solr-vufind':
    ensure  => 'link',
    target  => $solr_user_home,
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
