# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::destination_port::etcd {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy kubernetes etcd ${facts['hostname']}":
    target  => '/etc/haproxy/services.d/etcd.cfg',
    order   => '02',
    content => "  server ${facts['hostname']} ${facts['networking']['ip']}:2379 check\n",
    tag     => "${cluster_name}_haproxy_kubernetes_etcd",
  }

  @@concat_fragment { "prometheus etcd service ${facts['hostname']}":
    tag     => "${facts['datacenter']}_prometheus_etcd_service_list",
    target  => '/etc/prometheus/etcd.yml',
    content => template('nebula/profile/prometheus/exporter/etcd/target.yaml.erb')
  }
}
