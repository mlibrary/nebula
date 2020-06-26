# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::www_lib::register_for_load_balancing {
  @@nebula::haproxy::binding {
    default:
      https_offload => false,
      datacenter    => $::datacenter,
      hostname      => $::hostname,
      ipaddress     => $::ipaddress,
    ;

    "${::hostname} www-lib":
      service => 'www-lib',
    ;

    "${::hostname} deepblue":
      service => 'deepblue',
    ;
  }
}
