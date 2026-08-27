# nebula::profile::mariadb::server
#
# Manage mariadb-server
#
# @summary Install and configure mariadb-server, using mariadb apt repo
#
# @param backup_path Mount point for optional NFS mount for mariadb backups (default: "/mnt/backup")
# @param backup_nfs_target NFS mount target for mariadb backups. Set this to enable mounting. (example: "nfs.example.com/path/to/export")
# @param backup_nfs_options NFS mount options (default: "auto,hard")
# @param backup_cron_weekday Set this to enable backup cron. See puppet/cron docs for syntax. (examples: "*", "1,3,5", "1-5")
# @param backup_ignore_table Table(s) to ignore when running mariadb-dump
# @param backup_ignore_table_data Table(s) to only backup structure when running mariadb-dump
# @param extra_conf Arbitrary mariadb conf arguments. Expected to be a multi line string. (example: "log_bin = /var/log/mysql/mysql-bin.log\nserver_id = 123")
#
# @example
#   include nebula::profile::mariadb::server

class nebula::profile::mariadb::server (
  String                                      $backup_path              = '/mnt/backup',
  Optional[String]                            $backup_nfs_target        = undef,
  String                                      $backup_nfs_options       = 'auto,hard',
  Optional[Cron::Weekday]                     $backup_cron_weekday      = undef, # set to enable backup cron
  Optional[Variant[String, Array[String[1]]]] $backup_ignore_table      = undef,
  Optional[Variant[String, Array[String[1]]]] $backup_ignore_table_data = undef,
  Optional[String]                            $extra_conf               = undef,
) {
  @nebula::taghosts::tag { 'mariadb': }

  include nebula::profile::mariadb
  include nebula::profile::prometheus::exporter::mysql

  package { default:
    require => [Apt::Source['mariadb'], Package['mariadb-client']];
    'mariadb-server': ;
    'mariadb-backup': ;
  }

  # almost always needed for mariadb setup, not a hard dependency
  stdlib::ensure_packages('rsync')

  # /usr/bin/mariabackup is a useless symlink, breaks tab completion
  file { '/usr/bin/mariabackup':
    ensure  => absent,
    require => Package['mariadb-backup'];
  }

  service { 'mariadb':
    ensure  => 'running',
    enable  => true,
    require => Package['mariadb-server'],
  }

  file { '/etc/mysql/mariadb.conf.d/90-mlibrary.cnf':
    content => template('nebula/mariadb/my.cnf.erb'),
    require => Package['mariadb-server'],
    notify  => Service['mariadb'],
  }

  if $backup_nfs_target {
    ensure_packages([
      'nfs-common',
      'zstd',
    ])

    file { $backup_path: ensure => directory }

    mount { $backup_path:
      ensure  => 'mounted',
      device  => $backup_nfs_target,
      options => $backup_nfs_options,
      fstype  => 'nfs',
      require => [Package['nfs-common'], File[$backup_path]],
    }

    $_backup_ignore_table = $backup_ignore_table ? {
      undef   => [],
      String  => [$backup_ignore_table],
      default => $backup_ignore_table
    }
    $_backup_ignore_table.each |String $t| {
      if $t !~ /^[A-Za-z0-9_]+\.[A-Za-z0-9_]+$/ {
        fail("nebula::profile::mariadb::server: backup_ignore_table entry '${t}' must be a valid MariaDB table name (e.g. 'my_db.my_table')")
      }
    }
    $_backup_ignore_table_data = $backup_ignore_table_data ? {
      undef   => [],
      String  => [$backup_ignore_table_data],
      default => $backup_ignore_table_data
    }
    $_backup_ignore_table_data.each |String $t| {
      if $t !~ /^[A-Za-z0-9_]+\.[A-Za-z0-9_]+$/ {
        fail("nebula::profile::mariadb::server: backup_ignore_table_data entry '${t}' must be a valid MariaDB table name (e.g. 'my_db.my_table')")
      }
    }

    file { '/usr/local/bin/backup_db':
      content => template('nebula/mariadb/backup_db.erb'),
      mode    => '0755',
      require => Package['zstd'],
    }

    if $backup_cron_weekday {
      cron::job { 'backup_db':
        command     => '/usr/local/bin/backup_db',
        minute      => fqdn_rand(60,'backup_db minute'),
        hour        => fqdn_rand(3,'backup_db hour'),
        weekday     => $backup_cron_weekday,
        environment => [
          'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"',
        ],
        description => "nebula::profile::mariadb::server: backup mariadb to ${backup_path}",
      }
    } else {
      cron::job { 'backup_db': ensure => absent }
    }
  } else {
    # we don't want this script to exist if we don't have an nfs mount to write to
    file { '/usr/local/bin/backup_db': ensure => absent }
    cron::job { 'backup_db': ensure => absent }

    if $backup_cron_weekday {
      fail('backup_cron_weekday may not be set without setting backup_nfs_target')
    }
  }
}
