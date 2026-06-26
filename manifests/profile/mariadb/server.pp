# install and configure mariadb-server, using mariadb apt repo
class nebula::profile::mariadb::server (
  String $backup_path = '/mnt/backup',
  Optional[String] $backup_nfs_target = undef,
  String $backup_nfs_options = 'auto,hard',
  Optional[String] $extra_conf = undef,
) {
  @nebula::taghosts::tag { 'mariadb': }

  include nebula::profile::mariadb

  package { default:
    require => [Apt::Source['mariadb'], Package['mariadb-client']];
    'mariadb-server': ;
    'mariadb-backup': ;
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
    ensure_packages(['nfs-common'])

    file { $backup_path: ensure => directory }

    mount { $backup_path:
      ensure  => 'mounted',
      device  => $backup_nfs_target,
      options => $backup_nfs_options,
      fstype  => 'nfs',
      require => [Package['nfs-common'], File[$backup_path]],
    }
  }
}
