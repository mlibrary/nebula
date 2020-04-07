# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HAProxy settings for webhost hosting quod.lib.umich.edu
#
# @example
#   include nebula::profile::quod::prod::haproxy
class nebula::profile::quod::prod::haproxy {
  @@nebula::haproxy::binding { "${::hostname} quod":
    service       => 'quod',
    https_offload => true,
    datacenter    => $::datacenter,
    hostname      => $::hostname,
    ipaddress     => $::ipaddress;
  }
}
