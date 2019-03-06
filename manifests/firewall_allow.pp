# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Shorthand for allowing firewall connections.
define nebula::firewall_allow (
  $port,
  $source,
  $order = 300,
  $proto = 'tcp',
) {
  $cidrs = lookup("nebula::known_addresses::${source}")

  $cidrs.flatten.each |$index, $cidr| {
    firewall { "${order} ${title} ${index}":
      proto  => $proto,
      dport  => $port,
      source => $cidr,
      state  => 'NEW',
      action => 'accept',
    }
  }
}
