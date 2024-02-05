# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::kubeadm {
  include nebula::profile::containerd
  include nebula::profile::kubernetes::kubelet

  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]

  case $cluster['kubernetes_version'] {
    Hash: {
      $kubernetes_major_version = $cluster['kubernetes_version']['major']
      $kubernetes_minor_version = $cluster['kubernetes_version']['minor']
      $kubernetes_patch_version = $cluster['kubernetes_version']['patch']
      $kubernetes_revision_version = $cluster['kubernetes_version']['revision']
      $kubernetes_version = "${kubernetes_major_version}.${kubernetes_minor_version}.${kubernetes_patch_version}"
    }

    default: {
      # This branch can be safely deleted once all kubernetes versions
      # are in hiera as hashes.
      $kubernetes_version = $cluster['kubernetes_version']
      $kubernetes_revision_version = '00'
    }
  }


  package { 'kubeadm':
    ensure  => "${kubernetes_version}-${kubernetes_revision_version}",
    require => [Apt::Source['kubernetes']],
  }

  apt::pin { 'kubeadm':
    packages => ['kubeadm'],
    version  => "${kubernetes_version}-${kubernetes_revision_version}",
    priority => 999,
  }

  include nebula::profile::networking::sysctl

  file { '/etc/sysctl.d/kubernetes_cluster.conf':
    content => template('nebula/profile/kubernetes/kubeadm_sysctl.conf.erb'),
    notify  => Service['procps'],
  }
}
