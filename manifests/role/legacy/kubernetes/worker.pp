# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes worker node
class nebula::role::legacy::kubernetes::worker {
  class { 'nebula::role::minimum':
    internal_routing => 'kubernetes_calico',
  }

  include nebula::profile::legacy::kubernetes::worker
}
