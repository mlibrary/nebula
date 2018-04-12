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
  class { 'nebula::role::umich':
    bridge_network => true,
  }

  include nebula::profile::vmhost::host
}
