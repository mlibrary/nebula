# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Exposed port
#
# This exposes a port (or range of ports) to any number of ip blocks
# that are defined in hieradata. For example, you might have hiera that
# looks like this:
#
# ```
# one_building:
# - name: One building
#   block: 10.1.2.0/24
#
# another_building:
# - name: Another building (1)
#   block: 10.2.4.0/24
# - name: Another building (2)
#   block: 10.3.4.0/24
#
# both_buildings:
# - "%{alias('one_building')}"
# - "%{alias('another_building')}"
# ```
#
# With this, you could expose a port to `one_building`,
# `another_building`, or to `both_buildings` with a single resource.
# This is ideal if you find yourself repeatedly opening different ports
# to the same large list of IP blocks. This way the details of which
# port gets opened are in the structure, but the details of what they're
# opened to are in the private hieradata.
#
# @param port The port or ports to open; can be a single port, or
#   multiple ports can be indicated with arrays of ports or with strings
#   of the form "123-456" (which would open all ports in that range)
# @param block The name to look up in your hieradata
# @param protocol An optional protocol (defaults to tcp)
#
# @example Opening ssh to `another_building`
#   nebula::exposed_port { '100 ssh':
#     port  => 22,
#     block => 'another_building',
#   }
#
# @example Opening 2 ports to `both_buildings`
#   nebula::exposed_port { '200 web':
#     port  => [80, 443],
#     block => 'both_buildings',
#   }
#
# @example Opening a range of udp ports to `one building`:
#   nebula::exposed_port { '300 21xxx for some reason':
#     port     => '21000-21999',
#     block    => 'one building',
#     protocol => 'udp',
#   }
define nebula::exposed_port(
  $port,
  String $block,
  String $protocol = 'tcp',
) {
  lookup($block).flatten.unique.each |$cidr| {
    firewall { "${title}: ${cidr['name']}":
      proto  => $protocol,
      dport  => $port,
      source => $cidr['block'],
      state  => 'NEW',
      jump   => 'accept',
    }
  }
}
