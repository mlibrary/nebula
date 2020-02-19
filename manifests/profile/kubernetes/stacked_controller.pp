# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes Stacked Controller profile
#
# This is two types of node at the same time: a controller and an etcd
# node. For more information, see ADR-3.
#
# This profile opens up necessary ports and creates a config file needed
# to start a kubernetes cluster with a highly-available pool of
# controller nodes.
#
# It does not actually start kubernetes or ensure that kubernetes is
# running. Due to the finicky nature of the bootstrapping process,
# puppet's responsibility ends when the servers simply have the desired
# software installed.
class nebula::profile::kubernetes::stacked_controller {
  include nebula::profile::kubernetes

  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $control_dns = $cluster['control_dns']
  $kubernetes_version = $cluster['kubernetes_version']
  $service_cidr = pick($cluster['service_cidr'], lookup('nebula::profile::kubernetes::service_cidr'))
  $pod_cidr = pick($cluster['pod_cidr'], lookup('nebula::profile::kubernetes::pod_cidr'))

  concat_file { 'kubeadm config':
    path   => '/etc/kubeadm_config.yaml',
    format => 'yaml',
  }

  concat_fragment {
    default:
      target => 'kubeadm config',
    ;

    'kubeadm config apiVersion':
      content => "apiVersion: 'kubeadm.k8s.io/v1beta1'",
    ;

    'kubeadm config kind':
      content => "kind: 'ClusterConfiguration'",
    ;

    'kubeadm config kubernetesVersion':
      content => "kubernetesVersion: '${kubernetes_version}'",
    ;

    'kubeadm config controlPlaneEndpoint':
      content => "controlPlaneEndpoint: '${control_dns}:6443'",
    ;

    'kubeadm config networking.serviceSubnet':
      content => "networking: {serviceSubnet: '${service_cidr}'}",
    ;

    'kubeadm config networking.podSubnet':
      content => "networking: {podSubnet: '${pod_cidr}'}",
    ;
  }

  @@firewall {
    default:
      proto  => 'tcp',
      source => $::ipaddress,
      state  => 'NEW',
      action => 'accept',
    ;

    # Controller nodes will need to access etcd nodes over 2379,2380 for
    # etcd.
    "200 ${cluster_name} etcd ${::fqdn}":
      tag   => "${cluster_name}_etcd",
      dport => [2379, 2380],
    ;
  }

  # Controller nodes accept connections from all nodes in this cluster
  # for the main API.
  Firewall <<| tag == "${cluster_name}_API" |>>

  # Controller nodes (stacked with etcd) accept connections from each
  # other for etcd.
  Firewall <<| tag == "${cluster_name}_etcd" |>>

  # Controller nodes accept connections from each other for kubelet.
  Firewall <<| tag == "${cluster_name}_kubelet" |>>

  # Controller nodes should listen for kubernetes connections.
  Firewall <<| tag == "${cluster_name}_haproxy_kubectl" |>>

  @@concat_fragment { "haproxy kubectl ${::hostname}":
    target  => '/etc/haproxy/haproxy.cfg',
    order   => '02',
    content => "  server ${::hostname} ${::ipaddress}:6443 check\n",
    tag     => "${cluster_name}_haproxy_kubectl",
  }

  @@concat_fragment { "haproxy ip ${::hostname}":
    target  => '/etc/kubernetes_addresses.yaml',
    content => "addresses: {control: {${::hostname}: '${::ipaddress}'}}",
    tag     => "${cluster_name}_proxy_ips",
  }
}
