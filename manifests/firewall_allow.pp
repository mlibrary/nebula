# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::firewall_allow
#
# Shorthand for allowing connections from CIDRs specified in hiera under
# `nebula::known_addresses::`, so, if we set the source to `friends`,
# this will look for CIDRs in `nebula::known_addresses::friends`.
#
# This way we can categorize IP ranges in our hiera data while nebula
# can keep its boots free of the grit of minutia, dealing only with our
# category names.
#
# In the following examples, let's assume you've set this in your hiera:
#
#     nebula::known_addresses::lowest:
#     - 10.0.0.0/32
#     nebula::known_addresses::highest:
#     - 10.255.255.255/32
#     nebula::known_addresses::low_three:
#     - 10.0.1.0/24
#     - 10.0.2.0/24
#     - 10.0.3.0/24
#     nebula::known_addresses::all:
#     - "%{alias('nebula::known_addresses::lowest')}"
#     - "%{alias('nebula::known_addresses::highest')}"
#     - "%{alias('nebula::known_addresses::low_three')}"
#
# @param port The port (or array of ports) to allow connections on
# @param source The category (or array of categories) to allow
#   communication over that port
# @param order The order number (defaults to 300)
# @param proto The protocol (defaults to tcp)
#
# @example Allowing low_three over SSH
#   # This will define three `firewall` resources named `300 Example 0`,
#   # `300 Example 1`, and `300 Example 2`, allowing each of the three
#   # IP ranges under `low_three` access to port 22.
#   nebula::firewall_allow { 'Example':
#     port   => 22,
#     source => 'low_three',
#   }
#
# @example Allowing low_three over HTTP/HTTPS
#   # This will define three `firewall` resources named `300 Web 0`,
#   # `300 Web 1`, and `300 Web 2`, allowing each of the three IP ranges
#   # under `low_three` access to ports 80 and 443.
#   nebula::firewall_allow { 'Web':
#     port   => [80, 443],
#     source => 'low_three',
#   }
#
# @example Opening with udp with an early order number
#   # This will define one `firewall` resource named `005 Windows? 0`,
#   # and it will allow 10.0.0.0 UDP access to port 1234.
#   nebula::firewall_allow { 'Windows?':
#     port   => 1234,
#     source => 'lowest',
#     order  => '005',
#     proto  => 'udp',
#   }
define nebula::firewall_allow (
  $port,
  $source,
  $order = 300,
  $proto = 'tcp',
) {
  $cidrs = [$source].flatten.map |$s| {
    lookup("nebula::known_addresses::${s}")
  }

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
