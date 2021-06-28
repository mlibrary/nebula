# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Unison Sync servers
#
# @example
#   include nebula::role::unison
class nebula::role::unison (
  String $private_address_template = '192.168.0.%s'
){
  include nebula::role::umich
  include nebula::profile::unison

  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }
}
