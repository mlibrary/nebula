# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# The minimum configuration for a host that logically belongs to the
# University of Michigan. Most--but not all--other roles rely on this
# one.
#
# @example
#   include nebula::role::umich
class nebula::role::umich (
  $bridge_network = false,
  $internal_routing = '',
) {

  class { 'nebula::role::minimum':
    internal_routing => $internal_routing,
  }

  if $facts['os']['family'] == 'Debian' and $::lsbdistcodename != 'jessie' {
    include nebula::profile::duo
    include nebula::profile::exim4
    include nebula::profile::grub
    include nebula::profile::ntp
    include nebula::profile::tiger
    class { 'nebula::profile::networking':
      bridge => $bridge_network,
    }
  }

  include nebula::profile::dns::standard
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::prospectors::ulib

}
