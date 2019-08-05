class nebula::profile::nometheus {
  package { 'prometheus-node-exporter':
    ensure => 'purged',
  }

  file { '/etc/default/prometheus-node-exporter':
    ensure => 'absent',
  }

  user { 'prometheus':
    ensure => 'absent',
  }

  group { 'prometheus':
    ensure => 'absent',
  }
}
