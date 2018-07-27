# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# A server that hosts applications (named instances) served
# by puma
#
# @example
#   include nebula::role::appserver
class nebula::role::appserver (
  $bridge_network = false,
) {

  class { 'nebula::role::umich':
    bridge_network => $bridge_network,
  }

  include nebula::profile::named_instances
}
