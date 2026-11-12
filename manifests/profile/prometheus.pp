# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus (
  Array $alert_managers = [],
  Array $static_wmi_nodes = [],
  Array $static_nodes = [],
  String $client_ca = '/etc/prometheus/tls/ca.crt',
  String $client_cert = '/etc/prometheus/tls/tls.crt',
  String $client_key = '/etc/prometheus/tls/tls.key',
) {
  include nebula::profile::prometheus::prereqs
  include nebula::profile::prometheus::client_certs
  include nebula::profile::prometheus::https

  $ipaddrs = $facts["mlibrary_ip_addresses"]

  file { '/etc/prometheus/prometheus.yml':
    content => template('nebula/profile/prometheus/config.yml.erb'),
    notify  => Service['prometheus'],
    require => Exec['divert /etc/prometheus/prometheus.yml'],
  }

  file { '/etc/prometheus/rules.yml':
    content => template('nebula/profile/prometheus/rules.yml.erb'),
    notify  => Service['prometheus'],
    require => Package['prometheus'],
  }

  nebula::file_that_pulls_in_exported_fragments {
    default:
      notify  => Service['prometheus'],
      require => Package['prometheus'],
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

  ['public', 'private'].each |$network| {
    if $ipaddrs[$network] != undef and $ipaddrs[$network] != [] {
      @@concat::fragment { "02 pushgateway advanced ${network} url ${facts['datacenter']}":
        target  => '/usr/local/bin/pushgateway_advanced',
        content => "PUSHGATEWAY='http://${ipaddrs[$network][0]}:9091'\n",
      }

      $ipaddrs[$network].each |$address| {
        @@firewall {
          default:
            proto  => 'tcp',
            source => $address,
            state  => 'NEW',
            jump   => 'accept',
          ;

          "010 prometheus ${network} node exporter foo ${address}":
            tag   => "${facts['datacenter']}_prometheus_${network}_node_exporter",
            dport => 9100,
          ;

          "010 prometheus ${network} haproxy exporter foo ${address}":
            tag   => "${facts['datacenter']}_prometheus_${network}_haproxy_exporter",
            dport => 9101,
          ;

          "010 prometheus ${network} mysql exporter foo ${address}":
            tag   => "${facts['datacenter']}_prometheus_${network}_mysql_exporter",
            dport => 9104,
          ;

          "010 prometheus ${network} ipmi exporter foo ${address}":
            tag   => "${facts['datacenter']}_prometheus_${network}_ipmi_exporter",
            dport => 9290,
          ;

          "010 prometheus ${network} search catalog serve exporter foo ${address}":
            tag => "${facts['datacenter']}_prometheus_${network}_search_catalog_serve_exporter",
          ;

          "010 prometheus ${network} search catalog reindex exporter foo ${address}":
            tag => "${facts['datacenter']}_prometheus_${network}_search_catalog_reindex_exporter",
          ;

          "010 prometheus ${network} quod exporter foo ${address}":
            tag => "${facts['datacenter']}_prometheus_${network}_quod_exporter",
          ;
        }
      }
    }
  }

  Firewall <<| tag == "${facts['datacenter']}_pushgateway_node" |>>
}
