# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::nat_router
#
# This configures a node to act as a NAT router for outbound traffic.
# Any node claiming an IP address within this router's CIDR can be
# configured to use this router as its gateway.
#
# If such a node does this, it will be able to talk directly with all
# other nodes inside the CIDR. Otherwise, all outbound traffic will
# appear to the outside world as if it comes from this router.
#
# This profile makes no attempt to deal with inbound traffic. All it
# does is make outbound traffic appear to come from the router.
#
# @param ip_address The IP address to claim when talking to the outside
#   world
# @param cidr The CIDR for the internal network
class nebula::profile::nat_router (
  String $ip_address,
  String $cidr,
) {
  include nebula::profile::networking::sysctl

  file { '/etc/sysctl.d/nat_router.conf':
    content => "net.ipv4.ip_forward = 1\n",
    notify  => Service['procps'],
  }

  firewall { '001 Do not NAT internal requests':
    table       => 'nat',
    chain       => 'POSTROUTING',
    action      => 'accept',
    proto       => 'all',
    source      => $cidr,
    destination => $cidr,
  }

  firewall { '002 Give external requests our public IP address':
    table    => 'nat',
    chain    => 'POSTROUTING',
    jump     => 'SNAT',
    proto    => 'all',
    source   => $cidr,
    tosource => $ip_address,
  }
}
