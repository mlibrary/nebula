# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::networking::firewall::private_ssh (
  Array[String] $cidrs = [],
  Integer $port = 22
) {
  $cidrs.each |$cidr| {
    firewall { "100 Private SSH: ${cidr}":
      state  => 'NEW',
      action => 'accept',
      dport  => $port,
      source => $cidr,
      proto  => 'tcp'
    }
  }
}
