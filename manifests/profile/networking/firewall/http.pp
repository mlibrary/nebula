# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::firewall::http
#
# Manage firewall (iptables) settings for HTTP/s
#
# @example
#   include nebula::profile::networking::firewall::http
class nebula::profile::networking::firewall::http () {
  nodes_for_class('nebula::profile::haproxy').each |String $nodename| {
    $node_net = fact_for($nodename, 'networking')

    firewall { "200 HTTP: HAProxy ${nodename}":
      proto     => 'tcp',
      dport     => [80, 443],
      source => $node_net['ip'],
      tcp_flags => 'SYN,RST,ACK,FIN SYN', # equivalent to --syn
      action    => 'accept',
    }
  }

}
