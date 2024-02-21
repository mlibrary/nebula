# Copyright (c) 2020, 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::bootstrap::etcd_config {
  include nebula::profile::kubernetes::kubelet
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]

  $router_address = $cluster['router_address']
  $private_domain = $cluster['private_domain']
  $initial_cluster = $cluster['etcd_initial_cluster']

  file { '/etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf':
    content => template('nebula/profile/kubernetes/bootstrap/etcd/systemd.conf.erb'),
    require => Package['kubelet'],
    notify  => Exec['kubelet reload daemon'],
  }

  $pod_manifest_path = "/etc/kubernetes/manifests"
  file { "/etc/kubernetes/kubelet.yaml":
    content => template("nebula/profile/kubelet/config.yaml.erb"),
    require => Package["kubelet"],
    notify  => Service["kubelet"],
  }

  file { '/etc/systemd/system/kubelet.service.d':
    ensure => 'directory',
  }

  if $initial_cluster {
    file { '/tmp/etcd.yaml':
      ensure => 'file',
      content => template('nebula/profile/kubernetes/etcd/etcd.yaml.erb'),
    }
  }

  exec { 'kubelet reload daemon':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service['kubelet'],
  }
}
