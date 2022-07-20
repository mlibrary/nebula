# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::kubelet {
  include nebula::profile::kubernetes::apt

  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]

  $kubernetes_version = $cluster['kubernetes_version']
  $public_address = $cluster['public_address']
  $router_address = $cluster['router_address']
  $etcd_address = $cluster['etcd_address']
  $kube_api_address = $cluster['kube_api_address']
  $node_cidr = pick($cluster['node_cidr'], lookup('nebula::profile::kubernetes::node_cidr'))

  if $kubernetes_version == undef {
    fail('You must set a specific kubernetes version')
  }

  if $public_address == undef {
    fail('You must set a public IP address for the cluster')
  }

  if $router_address == undef {
    fail("You must set a router IP address for the cluster's gateway")
  }

  if $etcd_address == undef {
    fail("You must set an etcd IP address for the cluster's gateway")
  }

  if $kube_api_address == undef {
    fail("You must set a kube api IP address for the cluster's gateway")
  }

  service { 'kubelet':
    ensure  => 'running',
    enable  => true,
    require => Package['kubelet'],
  }

  package { 'kubelet':
    ensure  => "${kubernetes_version}-00",
    require => Apt::Source['kubernetes'],
  }

  apt::pin { 'kubelet':
    packages => ['kubelet'],
    version  => "${kubernetes_version}-00",
    priority => 999,
  }

  firewall {
    default:
      proto  => 'tcp',
      source => $node_cidr,
      state  => 'NEW',
      action => 'accept',
    ;

    '200 Cluster ssh':
      dport => 22,
    ;

    '200 Cluster BGP':
      dport => 179,
    ;

    '200 Cluster VXLAN':
      dport => 4789,
      proto => 'udp',
    ;

    '200 Cluster etcd':
      dport => ['2379', '2380'],
    ;

    '200 Cluster kubelet':
      dport => 10250,
    ;

    '200 Cluster kubernetes API':
      dport => 6443,
    ;

    '200 Cluster NodePorts':
      dport => '30000-32767',
    ;

    '200 Cluster Prometheus':
      dport => 9100,
    ;
  }
}
