# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::bootstrap::source {
  include nebula::profile::kubernetes::bootstrap::user

  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $keys = pick($cluster['bootstrap_keys'], lookup('nebula::profile::kubernetes::bootstrap_keys'))

  file { '/var/lib/kubeadm_bootstrap/.ssh/id_rsa.pub':
    owner   => 'kubeadm_bootstrap',
    content => $keys['public'],
  }

  file { '/var/lib/kubeadm_bootstrap/.ssh/id_rsa':
    owner   => 'kubeadm_bootstrap',
    mode    => '0600',
    content => $keys['private'],
  }
}
