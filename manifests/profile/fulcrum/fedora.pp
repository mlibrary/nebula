# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::fedora

class nebula::profile::fulcrum::fedora (
  String $fedora_username = 'fedora',
  String $fedora_password = lookup('nebula::profile::fulcrum::mysql::fedora_password'),
) {
  ensure_packages([
    'tomcat9-user',
  ])

  file { '/etc/sudoers.d/fedora':
    content => template('nebula/profile/fulcrum/sudoers-fedora.erb'),
  }

  exec { 'create fedora tomcat':
    command => '/usr/bin/tomcat9-instance-create fedora',
    cwd     => '/opt',
    creates => '/opt/fedora',
    require => [
      User['fulcrum'],
      Package['tomcat9-user'],
    ],
  }

  file {
    ['/var/lib/fedora', '/var/log/fedora', '/opt/fedora', '/tmp/fedora']:
      ensure => directory,
      owner  => 'fulcrum',
      group  => 'fulcrum',
      require => Exec['create fedora tomcat'],
    ;
  }

  exec { 'chown -r /opt/fedora':
    command => 'chown -R fulcrum:fulcrum /opt/fedora',
    require => Exec['create fedora tomcat'],
  }

  file { '/opt/fedora/logs':
    ensure  => 'symlink',
    owner   => 'fulcrum',
    group   => 'fulcrum',
    force   => true,
    target  => '/var/log/fedora',
    require => Exec['create fedora tomcat'],
  }

  archive { '/opt/fedora/webapps/fedora.war':
    ensure        => present,
    extract       => false,
    source        => 'https://github.com/fcrepo/fcrepo/releases/download/fcrepo-4.7.6/fcrepo-webapp-4.7.6.war',
    checksum      => '5882d8a4dc8b3817374503dff2043be79d9bbd72',
    checksum_type => 'sha1',
    cleanup       => false,
    user          => 'fulcrum',
    group         => 'fulcrum',
    require       => Exec['create fedora tomcat'],
    notify        => Service['fedora'],
  }

  file { '/opt/fedora/repository.json':
    owner   => 'fulcrum',
    group   => 'fulcrum',
    content => template('nebula/profile/fulcrum/repository.json.erb'),
    require => Exec['create fedora tomcat'],
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
      File['/var/lib/fedora'],
      Archive['/opt/fedora/webapps/fedora.war'],
      Service['mysqld'],
    ],
  }
}
