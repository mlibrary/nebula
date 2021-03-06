# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting quod.lib.umich.edu
#
# @example
#   include nebula::role::webhost::quod
class nebula::role::webhost::quod {
  include nebula::role::umich

  @@nebula::haproxy::binding { "${::hostname} quod":
    service       => 'quod',
    https_offload => true,
    datacenter    => $::datacenter,
    hostname      => $::hostname,
    ipaddress     => $::ipaddress;
  }
}
