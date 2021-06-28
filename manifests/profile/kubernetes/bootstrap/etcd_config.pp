# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::bootstrap::etcd_config {
  include nebula::profile::kubernetes::kubelet

  file { '/etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf':
    content => template('nebula/profile/kubernetes/bootstrap/etcd/systemd.conf.erb'),
    require => Package['kubelet'],
    notify  => Exec['kubelet reload daemon'],
  }

  file { '/etc/systemd/system/kubelet.service.d':
    ensure => 'directory',
  }

  exec { 'kubelet reload daemon':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service['kubelet'],
  }
}
