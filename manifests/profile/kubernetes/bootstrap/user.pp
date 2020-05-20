# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::bootstrap::user {
  user { 'kubeadm_bootstrap':
    home => '/var/lib/kubeadm_bootstrap',
  }

  file { '/var/lib/kubeadm_bootstrap':
    ensure => 'directory',
    owner  => 'kubeadm_bootstrap',
  }

  file { '/var/lib/kubeadm_bootstrap/.ssh':
    ensure => 'directory',
    owner  => 'kubeadm_bootstrap',
    mode   => '0700',
  }
}
