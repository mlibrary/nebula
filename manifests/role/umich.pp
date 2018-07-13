# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal umich server
#
# @example
#   include nebula::role::umich
class nebula::role::umich (
  $bridge_network = false,
) {
  class { 'nebula::profile::base':
    bridge_network => $bridge_network,
  }

  include nebula::profile::duo
  include nebula::profile::dns::standard
  include nebula::profile::elastic::metricbeat
}
