# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::fedora

class nebula::profile::fulcrum::fedora (
  String $fedora_username = 'fedora',
  String $fedora_password = lookup('nebula::profile::fulcrum::mysql::fedora_password'),
) {
  ensure_packages([
    'tomcat8',
    'tomcat8-user',
  ])

  file { '/etc/sudoers.d/fedora':
    content => template('nebula/profile/fulcrum/sudoers-fedora.erb'),
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

  # Mask the implicit tomcat8 service from the init.d file
  file { '/etc/systemd/system/tomcat8.service':
    ensure => 'symlink',
    target => '/dev/null',
    before => File['/etc/systemd/system/fedora.service'],
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
      Mysql::Db['fedora'],
    ],
  }
}
