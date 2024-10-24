# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::kubernetes::prometheus {
  include nebula::role::prometheus
  include nebula::profile::unattended_upgrades
  include nebula::profile::kubernetes::dns_client
  include nebula::profile::kubernetes::destination_port::prometheus
  class { 'nebula::profile::kubernetes::kubelet':
    install_kubelet => false,
  }
}
