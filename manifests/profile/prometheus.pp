# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus (
  Array $alert_managers = [],
  String $version = 'latest',
) {
  include nebula::profile::docker

  docker::run { 'prometheus':
    image            => "prom/prometheus:${version}",
    net              => 'host',
    extra_parameters => ['--restart=always'],
    volumes          => [
      '/etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml',
      '/etc/prometheus/rules.yml:/etc/prometheus/rules.yml',
      '/etc/prometheus/nodes.yml:/etc/prometheus/nodes.yml',
      '/opt/prometheus:/prometheus',
    ],
    require          => File['/opt/prometheus'],
  }

  file { '/etc/prometheus/prometheus.yml':
    content => template('nebula/profile/prometheus/config.yml.erb'),
    notify  => Docker::Run['prometheus'],
  }

  file { '/etc/prometheus/rules.yml':
    content => template('nebula/profile/prometheus/rules.yml.erb'),
    notify  => Docker::Run['prometheus'],
  }

  concat_file { '/etc/prometheus/nodes.yml':
    notify  => Docker::Run['prometheus'],
    require => File['/etc/prometheus'],
  }

  Concat_fragment <<| tag == "${::datacenter}_prometheus_node_service_list" |>>

  file { '/etc/prometheus':
    ensure => 'directory',
  }

  file { '/opt/prometheus':
    ensure => 'directory',
    owner  => 65534,
    group  => 65534,
  }

  nebula::exposed_port { '010 Prometheus HTTP':
    port  => 9090,
    block => 'umich::networks::all_trusted_machines',
  }

  @@firewall { "010 prometheus node exporter ${::hostname}":
    tag    => "${::datacenter}_prometheus_node_exporter",
    proto  => 'tcp',
    dport  => 9100,
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
  }
}
