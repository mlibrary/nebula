# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::postgres
#
# Configure postgres for tools.lib. Sets up a database both for jira and for
# confluence, a postgres backup cron job, and cron jobs for shipping the
# backups to S3 (if configured)
#
# @param s3_backup_dest The URL to the S3 bucket where the backups should be
# deposited, for example s3://my-backups/somewhere. If provided, the postgres
# database backups will be shipped to this S3 bucket on a daily basis.
#
# @param $pg_backup_dir The directory in which postgres backups will be placed.

# @example
#   include nebula::profile::tools_lib::postgres

class nebula::profile::tools_lib::postgres (
  String $mail_recipient,
  String $pg_backup_dir = '/var/local/pgbackup',
  Optional[String] $s3_backup_dest = undef,
) {
  class { 'postgresql::globals':
    encoding => 'UTF-8',
    locale   => 'C.UTF-8',
  }

  include 'postgresql::server'

  postgresql::server::db {
    'jira':
      user     => 'jira',
      password => postgresql_password('jira', lookup('nebula::profile::tools_lib::db::jira::password')),
    ;
    'confluence':
      user     => 'confluence',
      password => postgresql_password('confluence', lookup('nebula::profile::tools_lib::db::confluence::password')),
  }

  file { $pg_backup_dir:
    ensure  => 'directory',
    mode    => '2775',
    owner   => 'root',
    group   => 'postgres',
    require => Class['postgresql::server']
  }

  file { "${pg_backup_dir}/backup":
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/nebula/pg_backup',
    require => File[$pg_backup_dir]
  }

  cron { 'backup postgres databases':
    command => "cd ${pg_backup_dir} && ( ./backup confluence; ./backup jira ) > pgbackup.log 2>&1",
    user    => 'postgres',
    hour    => 0,
    minute  => 7,
    require => Class['postgresql::server']
  }

  if($s3_backup_dest) {
    ensure_packages(['awscli'])

    cron {
      default:
        environment => ["MAILTO=${mail_recipient}"],
        user        => 'root';

      'backup postgres confluence dump to s3':
        command => "/usr/bin/aws s3 cp --quiet ${pg_backup_dir}/confluence.dump ${s3_backup_dest}",
        minute  => 10,
        hour    => 1;

      'backup postgres jira dump to s3':
        command => "/usr/bin/aws s3 cp --quiet ${pg_backup_dir}/jira.dump ${s3_backup_dest}",
        minute  => 10,
        hour    => 1
    }
  }

}
