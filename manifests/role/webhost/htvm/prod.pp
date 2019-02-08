# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::htvm::prod
class nebula::role::webhost::htvm::prod {
  include nebula::role::webhost::htvm
  include nebula::profile::hathitrust::apache::logs

  @@nebula::haproxy::binding { "${::hostname} hathitrust":
    service       => 'hathitrust',
    https_offload => false,
    datacenter    => $::datacenter,
    hostname      => $::hostname,
    ipaddress     => $::ipaddress
  }
}
