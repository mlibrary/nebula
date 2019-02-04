# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::hathitrust
class nebula::role::webhost::hathitrust {
  include nebula::role::hathitrust

  @@nebula::haproxy::binding { "${::hostname} hathitrust":
    service       => 'hathitrust',
    https_offload => true,
    datacenter    => $::datacenter,
    hostname      => $::hostname,
    ipaddress     => $::ipaddress
  }
}
