# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::app

class nebula::profile::fulcrum::app (
  String $fedora_username = 'fedora',
  String $fedora_password = lookup('nebula::profile::fulcrum::mysql::fedora_password'),
) {
  ensure_packages([
    'tomcat8',
    'tomcat8-user',
  ])

  group { 'fulcrum':
    gid => 717,
  }

  user { 'fulcrum':
    comment    => 'Fulcrum Application User',
    uid        => 717,
    gid        => 717,
    home       => '/home/fulcrum',
    managehome => true,
    require    => Group['fulcrum'],
  }

  file { '/var/local/fulcrum':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => User['fulcrum'],
  }

  file { '/var/local/fulcrum/repo':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => File['/var/local/fulcrum'],
  }

  exec { '/usr/bin/tomcat8-instance-create fedora':
    cwd     => '/home/fulcrum',
    user    => 'fulcrum',
    creates => '/home/fulcrum/fedora',
    require => Package['tomcat8-user'],
    before  => [
      Archive['/home/fulcrum/fedora/webapps/fedora.war'],
      File['/home/fulcrum/fedora/repository.json'],
    ]
  }

  archive { '/home/fulcrum/fedora/webapps/fedora.war':
    ensure        => present,
    extract       => false,
    source        => 'https://github.com/fcrepo/fcrepo/releases/download/fcrepo-4.7.4/fcrepo-webapp-4.7.4.war',
    checksum      => '11e06c843f40cf2b9f26bda94ddfe6d85d69a591',
    checksum_type => 'sha1',
    cleanup       => false,
    user          => 'fulcrum',
    group         => 'fulcrum',
    notify        => Service['fedora'],
  }

  file { '/home/fulcrum/fedora/repository.json':
    owner   => 'fulcrum',
    group   => 'fulcrum',
    content => template('nebula/profile/fulcrum/repository.json.erb'),
    notify  => Service['fedora'],
  }

  file { '/etc/default/fedora':
    content => template('nebula/profile/fulcrum/fedora.env.erb'),
    notify  => Service['fedora'],
  }

  file { '/etc/systemd/system/fedora.service':
    content => template('nebula/profile/fulcrum/fedora.service.erb'),
    notify  => Service['fedora'],
  }

  service { 'fedora':
    ensure  => 'running',
    enable  => true,
    require => [
      File['/etc/systemd/system/fedora.service'],
      File['/var/local/fulcrum/repo'],
      Archive['/home/fulcrum/fedora/webapps/fedora.war'],
      Mysql::Db['fulcrum'],
    ],
  }
}

