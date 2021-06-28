# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::kubernetes::etcd {
  class { 'nebula::role::minimum':
    internal_routing => 'kubernetes_calico',
  }

  include nebula::profile::ntp
  include nebula::profile::kubernetes::dns_client
  include nebula::profile::kubernetes::kubelet
  include nebula::profile::kubernetes::destination_port::etcd
  include nebula::profile::kubernetes::bootstrap::etcd_config
  include nebula::profile::kubernetes::bootstrap::destination
  include nebula::profile::kubernetes::register_for_keys::etcd
}
