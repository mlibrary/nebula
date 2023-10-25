# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::kubernetes::worker {
  class { 'nebula::role::minimum':
    internal_routing => 'kubernetes_calico',
  }

  include nebula::profile::ntp
  include nebula::profile::unattended_upgrades
  include nebula::profile::kubernetes::dns_client
  include nebula::profile::kubernetes::kubelet
  include nebula::profile::kubernetes::kubeadm
  include nebula::profile::kubernetes::filesystems
  include nebula::profile::kubernetes::prometheus
  include nebula::profile::kubernetes::destination_port::gelf_tcp
  include nebula::profile::kubernetes::destination_port::http
  include nebula::profile::kubernetes::destination_port::https
  include nebula::profile::kubernetes::destination_port::https_alt
  include nebula::profile::kubernetes::bootstrap::destination
  include nebula::profile::kubernetes::register_for_keys::worker
}
