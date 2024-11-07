# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::exporter::mysql ()
  {

  package { 'prometheus-mysqld-exporter': }

  service { 'prometheus-mysqld-exporter':
    ensure => 'running',
    enable => true,
  }

  file { '/etc/systemd/system/prometheus-mysqld-exporter.service':
    require => 'Package[prometheus-mysqld-exporter]',
    notify  => 'Service[prometheus-mysqld-exporter]',
    content => template('nebula/profile/prometheus/exporter/mysql/systemd.ini.erb')
  }

  file { '/etc/default/prometheus-mysqld-exporter':
    require => 'Package[prometheus-mysqld-exporter]',
    notify  => 'Service[prometheus-mysqld-exporter]',
    content => template('nebula/profile/prometheus/exporter/mysql/defaults.sh.erb')
  }

  @@concat_fragment { "prometheus mysql service ${::hostname}":
    tag     => "${::datacenter}_prometheus_mysql_service_list",
    target  => '/etc/prometheus/mysql.yml',
    content => template('nebula/profile/prometheus/exporter/mysql/target.yaml.erb')
  }

  Firewall <<| tag == "${::datacenter}_prometheus_mysql_exporter" |>>

  $role = lookup_role()

}
