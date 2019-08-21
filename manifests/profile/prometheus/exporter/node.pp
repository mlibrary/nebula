# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Prometheus node exporter
#
# Every node we want metrics on needs a node exporter installed, and
# it's best if they all have the same version of the exporter even if
# they're on different OS versions. So we maintain our own deb and
# maintain all configuration through puppet.
#
# Each node exports some service discovery lines to a scraper in the
# same datacenter if it can. It also opens port 9100 to that same
# scraper. If there isn't a dedicated scraper for this node's
# datacenter, then it'll default to a specified scraper elsewhere.
#
# @param version Optional version of the node exporter to install
# @param covered_datacenters A list of datacenters that have dedicated
#   Prometheus scrapers.
# @param default_datacenter If this node is in a datacenter that isn't
#   in the covered_datacenters list, it will be scraped by the scraper
#   in this datacenter instead.
class nebula::profile::prometheus::exporter::node (
  Optional[String] $version = undef,
  Array $covered_datacenters = [],
  String $default_datacenter = 'default',
) {
  include nebula::virtual::users
  include nebula::profile::groups

  file { '/etc/default/prometheus-node-exporter':
    content => template('nebula/profile/prometheus/exporter/node/defaults.sh.erb'),
    notify  => Service['prometheus-node-exporter'],
    require => Package['prometheus-node-exporter'],
  }

  file { '/etc/systemd/system/prometheus-node-exporter.service':
    content => template('nebula/profile/prometheus/exporter/node/systemd.ini.erb'),
    notify  => Service['prometheus-node-exporter'],
    require => Package['prometheus-node-exporter'],
  }

  service { 'prometheus-node-exporter':
    ensure => 'running',
    enable => true,
  }

  package { 'prometheus-node-exporter':
    ensure  => pick($version, 'installed'),
    require => [User['prometheus'], File['/var/lib/prometheus/node-exporter']],
  }

  file { '/var/lib/prometheus/node-exporter':
    ensure => 'directory',
    mode   => '2775',
    owner  => 'prometheus',
    group  => 'prometheus',
  }

  file { '/var/lib/prometheus':
    ensure => 'directory',
    mode   => '2775',
    owner  => 'prometheus',
    group  => 'prometheus',
  }

  realize User['prometheus']

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
    content => template('nebula/profile/prometheus/exporter/node/target.yaml.erb'),
  }

  Firewall <<| tag == "${monitoring_datacenter}_prometheus_node_exporter" |>>
}
