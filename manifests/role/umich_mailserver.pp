# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# A minimum configuration for a mail server host that logically belongs 
# the University of Michigan. 
# 
#
# @example
#   include nebula::role::umich_mailserver
class nebula::role::umich_mailserver (
  $bridge_network = false,
  $internal_routing = '',
) {

  class { 'nebula::role::minimum':
    internal_routing => $internal_routing,
  }

  if $facts['os']['family'] == 'Debian' {
    include nebula::profile::duo
    include nebula::profile::postfix
    include nebula::profile::grub
    include nebula::profile::ntp
    class { 'nebula::profile::networking':
      bridge => $bridge_network,
    }
  }

  include nebula::profile::dns::standard
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::prospectors::ulib

}
