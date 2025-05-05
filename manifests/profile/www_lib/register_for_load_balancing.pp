# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::www_lib::register_for_load_balancing (
  Array[String] $services = [],
) {
  $services.each |$service| {
    @@nebula::haproxy::binding { "${facts['hostname']} ${service}":
      service       => $service,
      datacenter    => $facts['datacenter'],
      hostname      => $facts['hostname'],
      ipaddress     => $facts['ip'],
      https_offload => false,
    }
  }
}
