# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::kubeadm_config {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $etcd_address = $cluster['etcd_address']
  $private_domain = $cluster['private_domain']
  $kubernetes_version = $cluster['kubernetes_version']
  $service_cidr = pick($cluster['service_cidr'], lookup('nebula::profile::kubernetes::service_cidr'))
  $pod_cidr = pick($cluster['pod_cidr'], lookup('nebula::profile::kubernetes::pod_cidr'))
  $dex_cluster_id = $cluster['dex_cluster_id']
  $dex_url = $cluster['dex_url']

  file { '/etc/kubeadm_config.yaml':
    content => template('nebula/profile/kubernetes/kubeadm_config.yaml.erb'),
  }
}
