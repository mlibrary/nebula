# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus (
  Array $alert_managers = [],
  Array $static_wmi_nodes = [],
  Array $static_nodes = [],
) {
  stdlib::ensure_packages([
    'prometheus',
    'prometheus-pushgateway',
  ])

  service { 'prometheus': }
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

  file { '/etc/prometheus/rules.yml':
    content => template('nebula/profile/prometheus/rules.yml.erb'),
    notify  => Service['prometheus'],
  }

  nebula::file_that_pulls_in_exported_fragments {
    default:
      notify       => Service['prometheus'],
      require      => Package['prometheus'],
    ;

    '/etc/prometheus/nodes.yml':
      fragment_tag => "${facts['datacenter']}_prometheus_node_service_list",
    ;

    '/etc/prometheus/haproxy.yml':
      fragment_tag => "${facts['datacenter']}_prometheus_haproxy_service_list",
    ;

    '/etc/prometheus/mysql.yml':
      fragment_tag => "${facts['datacenter']}_prometheus_mysql_service_list",
    ;

    '/etc/prometheus/ipmi.yml':
      fragment_tag => "${facts['datacenter']}_prometheus_ipmi_service_list",
    ;

    '/etc/prometheus/etcd.yml':
      fragment_tag => "${facts['datacenter']}_prometheus_etcd_service_list",
    ;

    '/etc/prometheus/catalog_search.yml':
      fragment_tag => "${facts['datacenter']}_prometheus_catalog_search_service_list",
    ;

    '/etc/prometheus/quod.yml':
      fragment_tag => "${facts['datacenter']}_prometheus_quod_service_list",
    ;
  }

  $static_nodes.each |$static_node| {
    concat::fragment { "prometheus node service ${static_node['labels']['hostname']}":
      target  => '/etc/prometheus/nodes.yml',
      content => template('nebula/profile/prometheus/exporter/node/static_target.yaml.erb'),
    }
  }

  concat::fragment { 'prometheus ipmi scrape config first line':
    target  => '/etc/prometheus/ipmi.yml',
    order   => '01',
    content => "scrape_configs:\n"
  }
}
