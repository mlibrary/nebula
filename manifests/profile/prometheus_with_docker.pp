# Copyright (c) 2019-2026 The Regents of the University of Michigan.
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
class nebula::profile::prometheus_with_docker (
  Array $alert_managers = [],
  Array $static_nodes = [],
  Array $static_wmi_nodes = [],
  Boolean $manage_https = true,
  Hash $rules_variables = {},
  String $version = 'latest',
  String $pushgateway_version = 'latest',
) {
  $hostname = $::networking['hostname']

  case $facts["mlibrary_ip_addresses"] {
    Hash[String, Array[String]]: {
      $all_public_addresses = $facts["mlibrary_ip_addresses"]["public"]
      $all_private_addresses = $facts["mlibrary_ip_addresses"]["private"]
    }

    default: {
      $all_public_addresses = [$::networking['ip']]
      $all_private_addresses = []
    }
  }

  ####################################################################

  if $all_public_addresses != [] {
    @@concat_fragment { "02 pushgateway advanced public url ${facts['datacenter']}":
      target  => '/usr/local/bin/pushgateway_advanced',
      content => "PUSHGATEWAY='http://${all_public_addresses[0]}:9091'\n",
    }

    # Legacy resource name, delete when no longer in use.
    @@concat_fragment { "02 pushgateway advanced url ${facts['datacenter']}":
      target  => '/usr/local/bin/pushgateway_advanced',
      content => "PUSHGATEWAY='http://${all_public_addresses[0]}:9091'\n",
    }
  }

  if $all_private_addresses != [] {
    @@concat_fragment { "02 pushgateway advanced private url ${facts['datacenter']}":
      target  => '/usr/local/bin/pushgateway_advanced',
      content => "PUSHGATEWAY='http://${all_private_addresses[0]}:9091'\n",
    }
  }

  ####################################################################

  $all_public_addresses.each |$address| {
    @@firewall {
      default:
        proto  => 'tcp',
        source => $address,
        state  => 'NEW',
        jump   => 'accept',
      ;

      "010 prometheus public node exporter ${::networking['hostname']} ${address}":
        tag   => "${facts['datacenter']}_prometheus_public_node_exporter",
        dport => 9100,
      ;

      "010 prometheus public ipmi exporter ${::networking['hostname']} ${address}":
        tag   => "${facts['datacenter']}_prometheus_public_ipmi_exporter",
        dport => 9290,
      ;

      "010 prometheus public search catalog serve exporter ${::networking['hostname']} ${address}":
        tag => "${facts['datacenter']}_prometheus_public_search_catalog_serve_exporter",
      ;

      "010 prometheus public search catalog reindex exporter ${::networking['hostname']} ${address}":
        tag => "${facts['datacenter']}_prometheus_public_search_catalog_reindex_exporter",
      ;
    }
  }

  $all_private_addresses.each |$address| {
    @@firewall {
      default:
        proto  => 'tcp',
        source => $address,
        state  => 'NEW',
        jump   => 'accept',
      ;

      "010 prometheus private node exporter ${::networking['hostname']} ${address}":
        tag   => "${facts['datacenter']}_prometheus_private_node_exporter",
        dport => 9100,
      ;

      "010 prometheus private ipmi exporter ${::networking['hostname']} ${address}":
        tag   => "${facts['datacenter']}_prometheus_private_ipmi_exporter",
        dport => 9290,
      ;

      "010 prometheus private search catalog serve exporter ${::networking['hostname']} ${address}":
        tag => "${facts['datacenter']}_prometheus_private_search_catalog_serve_exporter",
      ;

      "010 prometheus private search catalog reindex exporter ${::networking['hostname']} ${address}":
        tag => "${facts['datacenter']}_prometheus_private_search_catalog_reindex_exporter",
      ;

      "010 prometheus quod exporter ${::networking['hostname']} ${address}":
        tag => "${facts['datacenter']}_prometheus_private_quod_exporter"
      ;
    }
  }

  @@firewall { "010 prometheus haproxy exporter ${::networking['hostname']}":
    tag    => "${facts['datacenter']}_prometheus_haproxy_exporter",
    proto  => 'tcp',
    dport  => 9101,
    source => $::networking['ip'],
    state  => 'NEW',
    jump   => 'accept',
  }

  @@firewall { "010 prometheus mysql exporter ${::networking['hostname']}":
    tag    => "${facts['datacenter']}_prometheus_mysql_exporter",
    proto  => 'tcp',
    dport  => 9104,
    source => $::networking['ip'],
    state  => 'NEW',
    jump   => 'accept',
  }

  ####################################################################

  Firewall <<| tag == "${facts['datacenter']}_pushgateway_node" |>>
}
