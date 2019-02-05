# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::hathitrust::test
class nebula::role::webhost::hathitrust::test {
  @@nebula::haproxy::binding { "${::hostname} test-hathitrust":
    service       => 'test-hathitrust',
    https_offload => true,
    datacenter    => $::datacenter,
    hostname      => $::hostname,
    ipaddress     => $::ipaddress
  }
  include nebula::role::hathitrust::dev::app_host
}
