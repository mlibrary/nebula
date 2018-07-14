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
  include nebula::profile::base
  include nebula::profile::authorized_keys
  include nebula::profile::apt
  include nebula::profile::duo
  include nebula::profile::exim4
  include nebula::profile::grub
  include nebula::profile::ntp
  include nebula::profile::tiger
  include nebula::profile::vim
  include nebula::profile::dns::standard
  include nebula::profile::elastic::metricbeat

  class { 'nebula::profile::networking':
    bridge => $bridge_network,
    keytab => true
  }

}
