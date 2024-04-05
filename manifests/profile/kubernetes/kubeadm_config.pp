# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::kubeadm_config {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $etcd_address = $cluster['etcd_address']
  $private_domain = $cluster['private_domain']
  $service_cidr = pick($cluster['service_cidr'], lookup('nebula::profile::kubernetes::service_cidr'))
  $pod_cidr = pick($cluster['pod_cidr'], lookup('nebula::profile::kubernetes::pod_cidr'))
  $dex_cluster_id = $cluster['dex_cluster_id']
  $dex_url = $cluster['dex_url']

  $kubernetes_major_version = $cluster['kubernetes_version']['major']
  $kubernetes_minor_version = $cluster['kubernetes_version']['minor']
  $kubernetes_patch_version = $cluster['kubernetes_version']['patch']
  $kubernetes_version = "${kubernetes_major_version}.${kubernetes_minor_version}.${kubernetes_patch_version}"

  file { '/etc/kubeadm_config.yaml':
    content => template('nebula/profile/kubernetes/kubeadm_config.yaml.erb'),
  }
}
