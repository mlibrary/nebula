# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::mysql

class nebula::profile::fulcrum::mysql (
  String $fedora_password,
  String $fulcrum_password,
  String $checkpoint_password,
  String $shibd_password,
  String $password,
) {

  # Install and configure mysql server
  ensure_packages(['mariadb-common','mariadb-server', 'mariadb-client'])

# at some point need to do equivalent to `mysql_install_db --user=mysql --ldata=/var/lib/mysql`

  service { 'mysqld':
    enable  => true,
    ensure  => running,
    require => Package['mariadb-server'],
  }

  file { "/etc/mysql/conf.d":
    ensure => "directory"
  }

  file { "/etc/mysql/my.cnf":
    owner => "mysql", group => "mysql",
    content => template('nebula/mysql/my.cnf.erb'),
    notify => Service["mysqld"],
    require => Package["mariadb-server"],
  }

  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$password status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $password",
    require => Service["mysqld"],
  }

  $dbs = [['fedora', $fedora_password], ['fulcrum', $fulcrum_password],
  ['checkpoint', $checkpoint_password], ['shibd', $shibd_password]]

  $dbs.each |$db| {
    $name = $db[0]
    $password = $db[1]
    exec { "create-${name}-db":
      unless => "/usr/bin/mysql -u${name} -p${password} ${name}",
      command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"create database ${name}; grant all on ${name}.* to ${name}@localhost identified by '${password}';\"",
      require => Service["mysqld"],
    }
  }

}
