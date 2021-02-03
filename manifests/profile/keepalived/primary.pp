# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::keepalived::primary {
  include keepalived

  $scope = lookup('nebula::scope')

  lookup('nebula::profile::keepalived::ip_addresses', undef, undef, []).each |$index, $ip_address| {
    $id = $index + 50

    keepalived::vrrp::instance { "${datacenter}_${scope}_${id}":
      state             => 'MASTER',
      priority          => 101,
      interface         => pick_network_interface_for_ip($ip_address),
      virtual_router_id => $id,
      virtual_ipaddress => $ip_address,
    }
  }
}
