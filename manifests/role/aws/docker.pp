# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# AWS docker server
#
# This is a minimal aws server that leaves docker's internal routing
# alone instead of blowing it away every half hour.
class nebula::role::aws::docker {
  class { 'nebula::role::aws':
    internal_routing => 'docker',
  }
}
