# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::exporter::haproxy (
  Boolean $master,
) {

  package { 'prometheus-haproxy-exporter': }

  service { 'prometheus-haproxy-exporter':
    ensure => 'running',
    enable => true,
  }

  file { '/etc/systemd/system/prometheus-haproxy-exporter.service':
    require => 'Package[prometheus-haproxy-exporter]',
    notify  => 'Service[prometheus-haproxy-exporter]',
    content => template('nebula/profile/prometheus/exporter/haproxy/systemd.ini.erb')
  }

  file { '/etc/default/prometheus-haproxy-exporter':
    require => 'Package[prometheus-haproxy-exporter]',
    notify  => 'Service[prometheus-haproxy-exporter]',
    content => template('nebula/profile/prometheus/exporter/haproxy/defaults.sh.erb')
  }


  @@concat_fragment { "prometheus haproxy service ${::hostname}":
    tag     => "${::datacenter}_prometheus_haproxy_service_list",
    target  => '/etc/prometheus/haproxy.yml',
    content => template('nebula/profile/prometheus/exporter/haproxy/target.yaml.erb')
  }

  Firewall <<| tag == "${::datacenter}_prometheus_haproxy_exporter" |>>

}
