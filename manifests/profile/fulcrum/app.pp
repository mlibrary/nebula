# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::app

class nebula::profile::fulcrum::app (
  String $fedora_username = 'fedora',
  String $fedora_password = lookup('nebula::profile::fulcrum::mysql::fedora_password'),
  Array $authorized_keys = [],
) {
  include nebula::profile::networking::private

  ensure_packages([
    'clamav',
    'clamav-daemon',
    'clamav-freshclam',
    'libclamav-dev',
    'shared-mime-info',
    'tomcat8',
    'tomcat8-user',
    'unzip',
    'zip',
  ])

  class { 'nebula::profile::nodejs':
    version => '14',
  }

  exec { 'npm install -g yarn':
    path    => '/bin:/usr/bin',
    creates => '/usr/bin/yarn',
    require => Package['nodejs'],
  }

  group { 'fulcrum':
    gid => 717,
  }

  user { 'fulcrum':
    comment    => 'Fulcrum Application User',
    uid        => 717,
    gid        => 717,
    home       => '/home/fulcrum',
    shell      => '/bin/bash',
    managehome => true,
    require    => Group['fulcrum'],
  }

  nebula::file::ssh_keys { '/home/fulcrum/.ssh/authorized_keys':
    keys   => $authorized_keys,
    secret => true,
    owner  => 'fulcrum',
    group  => 'fulcrum',
  }

  file { '/etc/sudoers.d/fulcrum':
    content => template('nebula/profile/fulcrum/sudoers.erb'),
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

  file { '/var/local/fulcrum/data':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => File['/var/local/fulcrum'],
  }

  file { '/home/fulcrum/app':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => User['fulcrum'],
  }

  file { '/home/fulcrum/app/releases':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => File['/home/fulcrum/app'],
  }

  file { '/home/fulcrum/app/shared':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => File['/home/fulcrum/app'],
  }

  file { '/home/fulcrum/app/shared/tmp':
    ensure  => symlink,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    target  => '/var/local/fulcrum/tmp',
    require => File['/home/fulcrum/app/shared'],
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

  archive { '/tmp/fits.zip':
    ensure        => present,
    extract       => true,
    creates       => '/usr/local/fits/fits.sh',
    extract_path  => '/usr/local/fits',
    source        => 'https://projects.iq.harvard.edu/files/fits/files/fits-1.3.0.zip',
    checksum      => '9c1b020afdd2e9a65a62128fa5ec6a6f86f77de9',
    checksum_type => 'sha1',
    cleanup       => true,
    require       => File['/usr/local/fits'],
  }

  file { '/usr/local/fits':
    ensure => directory,
  }

  file { '/usr/local/bin/fits.sh':
    ensure => 'symlink',
    target => '/usr/local/fits/fits.sh',
  }

  file { '/etc/systemd/system/fulcrum.target':
    content => template('nebula/profile/fulcrum/fulcrum.target.erb'),
    notify  => Service['fulcrum'],
    require => [
      File['/etc/systemd/system/fulcrum-rails.service'],
      File['/etc/systemd/system/fulcrum-resque.service'],
    ]
  }

  file { '/etc/systemd/system/fulcrum-rails.service':
    content => template('nebula/profile/fulcrum/fulcrum-rails.service.erb'),
    notify  => Service['fulcrum'],
  }

  file { '/etc/systemd/system/fulcrum-resque.service':
    content => template('nebula/profile/fulcrum/fulcrum-resque.service.erb'),
    notify  => Service['fulcrum'],
  }

  file { '/etc/default/fulcrum':
    content => template('nebula/profile/fulcrum/fulcrum.env.erb'),
    notify  => Service['fulcrum'],
  }

  service { 'fulcrum':
    ensure  => 'running',
    enable  => true,
    require => [
      File['/etc/systemd/system/fulcrum.target'],
      Mysql::Db['fulcrum'],
    ],
  }
}
