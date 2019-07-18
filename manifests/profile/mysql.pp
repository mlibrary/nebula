# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::mysql
#
# @param password The root password, as stored by root's .my.cnf.
class nebula::profile::mysql (
  String $password,
  String $datadir = '/var/lib/mysql'
  String $backupdir = "${datadir}/backup"
) {

  #
  # Install and configure mysql server
  #
  class { 'mysql::server':
    create_root_user        => true,
    create_root_my_cnf      => true,
    root_password           => $password,
    remove_default_accounts => true,
  }

  #
  # Install the mysql client
  #
  class { 'mysql::client':
    bindings_enable => false
  }


  #
  # Setup mysql backups
  #

  # These are needed by the scripts we install and use
  ensure_packages([
    'pigz',
    'rsync'
  ])

  # Create directory structure and install templates
  file { "${backupdir}":
    ensure => 'directory',
  }

  file { "${backupdir}/weekbeforelast":
    ensure => 'directory',
  }

  file { "${backupdir}/lastweek":
    ensure => 'directory',
  }

  file { "${backupdir}/current":
    ensure => 'directory',
  }

  file { "${backupdir}/backup":
    ensure  => 'present',
    content => template('nebula/profile/mysql/backup.erb'),
  }

  file { "${backupdir}/rotate":
    ensure  => 'present',
    content => template('nebula/profile/mysql/rotate.erb'),
  }

  file { "${backupdir}/splitsqlbytable.pl":
    ensure  => 'present',
    content => template('nebula/profile/mysql/splitsqlbytable.pl'),
  }

  # Add the cronjob
  # This name will conflict with the one created by the puppetlabs mysql package.
  # This is intentional. It differs slightly from our historical name.
  cron { 'mysql-backup':
    command => "${backupdir}/backup | /usr/bin/mail -s 'mysql backup log (${::hostname})' lit-cs-backups@umich.edu",
    user    => 'root',
    minute  => 3,
    hour    => 22,
    weekday => 6
  }

}
