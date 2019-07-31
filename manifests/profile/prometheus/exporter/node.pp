# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::exporter::node (
  Array $covered_datacenters = [],
  String $default_datacenter = 'default',
) {
  file { '/etc/default/prometheus-node-exporter':
    content => template('nebula/profile/prometheus/exporter/node.sh.erb'),
    notify  => Service['prometheus-node-exporter'],
    require => Package['prometheus-node-exporter'],
  }

  service { 'prometheus-node-exporter':
    ensure => 'running',
    enable => true,
  }

  package { 'prometheus-node-exporter': }

  $role = lookup_role()
  $datacenter = $::datacenter
  $ipaddress = $::ipaddress
  $hostname = $::hostname

  if $datacenter in $covered_datacenters {
    $monitoring_datacenter = $datacenter
  } else {
    $monitoring_datacenter = $default_datacenter
  }

  @@concat_fragment { "prometheus node service ${hostname}":
    tag     => "${monitoring_datacenter}_prometheus_node_service_list",
    target  => '/etc/prometheus/nodes.yml',
    content => template('nebula/profile/prometheus/exporter/target.yaml.erb'),
  }

  Firewall <<| tag == "${monitoring_datacenter}_prometheus_node_exporter" |>>
}
