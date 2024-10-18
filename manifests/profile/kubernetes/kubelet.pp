# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::kubelet ( 
  Boolean $install_kubelet = true,
) {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]

  $public_address = $cluster['public_address']
  $router_address = $cluster['router_address']
  $etcd_address = $cluster['etcd_address']
  $kube_api_address = $cluster['kube_api_address']
  $node_cidr = pick($cluster['node_cidr'], lookup('nebula::profile::kubernetes::node_cidr'))

  $kubernetes_major_version = $cluster['kubernetes_version']['major']
  $kubernetes_minor_version = $cluster['kubernetes_version']['minor']
  $kubernetes_patch_version = $cluster['kubernetes_version']['patch']
  $kubernetes_revision_version = $cluster['kubernetes_version']['revision']
  $kubernetes_version = "${kubernetes_major_version}.${kubernetes_minor_version}.${kubernetes_patch_version}"

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

  if $install_kubelet { 
    class { "nebula::profile::kubelet":
      kubelet_version         => "${kubernetes_version}-${kubernetes_revision_version}",
      pod_manifest_path       => "/etc/kubernetes/manifests",
      manage_pods_with_puppet => false,
    }
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

    '200 Cluster Calico Typha':
      dport => 5473,
    ;
  }
}
