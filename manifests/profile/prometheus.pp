# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus (
  Array $alert_managers = [],
  Array $static_wmi_nodes = [],
) {
  package { 'prometheus': }
  service { 'prometheus': }
  package { 'prometheus-pushgateway': }
  service { 'prometheus-pushgateway': }

  exec { 'divert /etc/prometheus/prometheus.yml':
    creates => '/etc/prometheus/prometheus.yml.dist',
    command => '/usr/bin/dpkg-divert --rename --divert /etc/prometheus/prometheus.yml.dist --add /etc/prometheus/prometheus.yml',
    require => Package['prometheus'],
  }

  exec { 'divert /etc/default/prometheus-pushgateway':
    creates => '/etc/default/prometheus-pushgateway.dist',
    command => '/usr/bin/dpkg-divert --rename --divert /etc/default/prometheus-pushgateway.dist --add /etc/default/prometheus-pushgateway',
    require => Package['prometheus-pushgateway'],
  }

  file { '/etc/prometheus/prometheus.yml':
    content => template('nebula/profile/prometheus/config.yml.erb'),
    notify  => Service['prometheus'],
    require => Exec['divert /etc/prometheus/prometheus.yml'],
  }

  file { '/var/lib/prometheus/pushgateway':
    ensure => 'directory',
    owner  => 'prometheus',
    group  => 'prometheus',
  }

  file { '/etc/default/prometheus-pushgateway':
    content => "ARGS=\"--persistence.file=/var/lib/prometheus/pushgateway/archive\"\n",
    notify  => Service['prometheus-pushgateway'],
    require => [
      Exec['divert /etc/default/prometheus-pushgateway'],
      File['/var/lib/prometheus/pushgateway'],
    ]
  }
}
