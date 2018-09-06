# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::i40e
#
# Use Intel-provided i40e driver if the Intel X710 card is present
#
# @example
#   include nebula::profile::base::i40e
class nebula::profile::base::i40e {
  if $facts['network_cards'] and $facts['network_cards'].any |$card| { $card =~ /Intel.*X710/ } {
    package { 'i40e-dkms': }
  }
}
