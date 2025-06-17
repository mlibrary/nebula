# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::search::catalog::solr_monitor (
  String $serve_metrics_bin = '/opt/catalog/serve/bin/metrics',
  Integer $serve_metrics_port = 9983,
  String $serve_metrics_config = '/opt/catalog/serve/config/metrics.xml',
  String $reindex_metrics_bin = '/opt/catalog/reindex/bin/metrics',
  Integer $reindex_metrics_port = 9984,
  String $reindex_metrics_config = '/opt/catalog/reindex/config/metrics.xml',
) {
  $serve_port = lookup('nebula::profile::search::catalog::solr::serve_port', default_value => 8983)
  $reindex_port = lookup('nebula::profile::search::catalog::solr::reindex_port', default_value => 8984)

  service { 'metrics-catalog-serve':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/systemd/system/metrics-catalog-serve.service'],
  }

  service { 'metrics-catalog-reindex':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/systemd/system/metrics-catalog-reindex.service'],
  }

  file { '/etc/systemd/system/metrics-catalog-serve.service':
    content => template('nebula/profile/search_solr/catalog-serve-solr-metrics.service.erb'),
    notify  => Exec['catalog serve solr metrics reload systemd'],
  }

  file { '/etc/systemd/system/metrics-catalog-reindex.service':
    content => template('nebula/profile/search_solr/catalog-reindex-solr-metrics.service.erb'),
    notify  => Exec['catalog reindex solr metrics reload systemd'],
  }

  exec { 'catalog serve solr metrics reload systemd':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service['metrics-catalog-serve'],
  }

  exec { 'catalog reindex solr metrics reload systemd':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service['metrics-catalog-reindex'],
  }

  $all_public_addresses = $facts["mlibrary_ip_addresses"]["public"]
  $all_private_addresses = $facts["mlibrary_ip_addresses"]["private"]

  if $all_public_addresses == [] and $all_private_addresses == [] {
    fail('Host cannot be scraped without a public or private IP address')
  } elsif $all_private_addresses != [] {
    $ipaddress = $all_private_addresses[0]

    Firewall <<| tag == "${facts['datacenter']}_prometheus_private_search_catalog_serve_exporter" |>> {
      dport => $serve_metrics_port,
    }

    Firewall <<| tag == "${facts['datacenter']}_prometheus_private_search_catalog_reindex_exporter" |>> {
      dport => $reindex_metrics_port,
    }
  } else {
    $ipaddress = $all_public_addresses[0]

    Firewall <<| tag == "${facts['datacenter']}_prometheus_public_search_catalog_serve_exporter" |>> {
      dport => $serve_metrics_port,
    }

    Firewall <<| tag == "${facts['datacenter']}_prometheus_public_search_catalog_reindex_exporter" |>> {
      dport => $reindex_metrics_port,
    }
  }

  @@concat_fragment { "prometheus solr scrape config ${::networking['hostname']}":
    tag     => "${facts['datacenter']}_prometheus_catalog_search_service_list",
    target  => '/etc/prometheus/catalog_search.yml',
    order   => '02',
    content => template('nebula/profile/search_solr/prometheus_targets.yaml.erb')
  }
}
