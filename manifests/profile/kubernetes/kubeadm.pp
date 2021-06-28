# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::kubeadm {
  include nebula::profile::kubernetes::docker
  include nebula::profile::kubernetes::kubelet

  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]

  $kubernetes_version = $cluster['kubernetes_version']

  package { 'kubeadm':
    ensure  => "${kubernetes_version}-00",
    require => [Apt::Source['kubernetes'], Class['docker']],
  }

  apt::pin { 'kubeadm':
    packages => ['kubeadm'],
    version  => "${kubernetes_version}-00",
    priority => 999,
  }
}
