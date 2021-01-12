# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::keepalived::primary {
  include keepalived

  $scope = lookup('nebula::scope')

  lookup('nebula::profile::keepalived::ip_addresses', undef, undef, []).each |$index, $ip_address| {
    keepalived::vrrp::instance { "${datacenter} ${scope} ${ip_address}":
      state             => 'MASTER',
      priority          => 101,
      interface         => pick_network_interface_for_ip($ip_address),
      virtual_router_id => 50 + $index,
      virtual_ipaddress => $ip_address,
    }
  }
}
