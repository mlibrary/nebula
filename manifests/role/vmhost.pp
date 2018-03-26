# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::vmhost
#
# VM Host. A VM host should probably do nothing other than host VMs.
#
# @example
#   include nebula::role::vmhost
class nebula::role::vmhost {
  class { 'nebula::profile::base':
    bridge_network => true,
  }

  include nebula::profile::dns::standard
  include nebula::profile::metricbeat
  include nebula::profile::vmhost
}
