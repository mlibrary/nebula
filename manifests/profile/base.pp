# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base
#
# Disable mcollective on all machines and hpwdt on HP machines.
#
# @example
#   include nebula::profile::base
class nebula::profile::base (
  Boolean $bridge_network = false,
) {
  include nebula::profile::base::stop_mcollective
  include nebula::profile::base::blacklist_hpwdt

  if $facts['os']['release']['major'] == '9' {
    include nebula::profile::base::authorized_keys
    include nebula::profile::base::firewall::ipv4

    class { 'nebula::profile::base::sysctl':
      bridge => $bridge_network,
    }
  }
}
