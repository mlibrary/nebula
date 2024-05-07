# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::firewall::ssh
#
# Manage firewall (iptables) settings for SSH
#
# @example
#   include nebula::profile::networking::firewall::ssh
class nebula::profile::networking::firewall::http_datacenters (
  Array $networks = [],
) {

  $params = {
    proto  => 'tcp',
    dport  => [80, 443],
    state  => 'NEW',
    action => 'accept'
  }

  $networks.flatten.each |$network| {
    firewall { "200 HTTP: ${network['name']}":
      source => $network['block'],
      *      => $params
    }
  }
}
