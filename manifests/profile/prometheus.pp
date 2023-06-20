# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Prometheus scraper profile
#
# This is a profile designed to scrape metrics exported by the node
# exporters on physical and virtual machines. It scrapes only machines
# claiming to share its datacenter, but it pushes alerts to all defined
# alert managers.
#
# @param alert_managers A list of alert managers to push alerts to.
# @param static_nodes A list of nodes to scrape in addition to those
#   that don't export themselves via puppet.
# @param rules_variables A hash of values to make available to the rules
#   template
# @param version The version of prometheus to run.
class nebula::profile::prometheus (
  Array $alert_managers = [],
  Array $static_nodes = [],
  Array $static_wmi_nodes = [],
  Hash $rules_variables = {},
  String $version = 'latest',
  String $pushgateway_version = 'latest',
) {
  include nebula::profile::docker
  $hostname = $::hostname

  docker::run { 'prometheus':
    image            => "prom/prometheus:${version}",
    net              => 'host',
    extra_parameters => ['--restart=always'],
    volumes          => [
      '/etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml',
      '/etc/prometheus/rules.yml:/etc/prometheus/rules.yml',
      '/etc/prometheus/nodes.yml:/etc/prometheus/nodes.yml',
      '/etc/prometheus/haproxy.yml:/etc/prometheus/haproxy.yml',
      '/etc/prometheus/mysql.yml:/etc/prometheus/mysql.yml',
      '/etc/prometheus/tls:/tls',
      '/opt/prometheus:/prometheus',
    ],
    require          => File['/opt/prometheus', '/etc/prometheus/tls/ca.crt', '/etc/prometheus/tls/client.crt', '/etc/prometheus/tls/client.key'],
  }

  docker::run { 'pushgateway':
    image            => "prom/pushgateway:${pushgateway_version}",
    command          => '--persistence.file=/archive/pushgateway',
    net              => 'host',
    extra_parameters => ['--restart=always'],
    volumes          => ['/opt/pushgateway:/archive'],
    require          => File['/opt/pushgateway'],
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

  $static_nodes.each |$static_node| {
    concat_fragment { "prometheus node service ${static_node['labels']['hostname']}":
      tag     => "${::datacenter}_prometheus_node_service_list",
      target  => '/etc/prometheus/nodes.yml',
      content => template('nebula/profile/prometheus/exporter/node/static_target.yaml.erb'),
    }
  }

  Concat_fragment <<| tag == "${::datacenter}_prometheus_node_service_list" |>>

  concat_file { '/etc/prometheus/haproxy.yml':
    notify  => Docker::Run['prometheus'],
    require => File['/etc/prometheus'],
  }

  Concat_fragment <<| tag == "${::datacenter}_prometheus_haproxy_service_list" |>>

  concat_file { '/etc/prometheus/mysql.yml':
    notify  => Docker::Run['prometheus'],
    require => File['/etc/prometheus'],
  }

  Concat_fragment <<| tag == "${::datacenter}_prometheus_mysql_service_list" |>>

  file { '/etc/prometheus':
    ensure => 'directory',
  }

  file { '/etc/prometheus/tls':
    ensure => 'directory',
  }

  file { '/etc/prometheus/tls/ca.crt':
    source => 'puppet:///ssl-certs/prometheus-pki/ca.crt',
  }

  file { '/etc/prometheus/tls/client.crt':
    source => "puppet:///ssl-certs/prometheus-pki/${::fqdn}.crt",
  }

  file { '/etc/prometheus/tls/client.key':
    source => "puppet:///ssl-certs/prometheus-pki/${::fqdn}.key",
  }

  file { '/opt/prometheus':
    ensure => 'directory',
    owner  => 65534,
    group  => 65534,
  }

  file { '/opt/pushgateway':
    ensure => 'directory',
    owner  => 65534,
    group  => 65534,
  }

  class { 'nebula::profile::https_to_port':
    port => 9090,
  }

  nebula::exposed_port { '010 Prometheus HTTPS':
    port  => 443,
    block => 'umich::networks::all_trusted_machines',
  }

  @@concat_fragment { "02 pushgateway advanced url ${::datacenter}":
    target  => '/usr/local/bin/pushgateway_advanced',
    content => "PUSHGATEWAY='http://${::fqdn}:9091'\n",
  }

  @@firewall { "010 prometheus node exporter ${::hostname}":
    tag    => "${::datacenter}_prometheus_node_exporter",
    proto  => 'tcp',
    dport  => 9100,
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
  }

  @@firewall { "010 prometheus haproxy exporter ${::hostname}":
    tag    => "${::datacenter}_prometheus_haproxy_exporter",
    proto  => 'tcp',
    dport  => 9101,
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
  }

  @@firewall { "010 prometheus mysql exporter ${::hostname}":
    tag    => "${::datacenter}_prometheus_mysql_exporter",
    proto  => 'tcp',
    dport  => 9104,
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
  }

  Firewall <<| tag == "${::datacenter}_pushgateway_node" |>>
}
