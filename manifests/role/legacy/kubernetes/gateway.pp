# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes gateway node
class nebula::role::legacy::kubernetes::gateway {
  include nebula::role::minimum
  include nebula::profile::legacy::kubernetes::haproxy
}
