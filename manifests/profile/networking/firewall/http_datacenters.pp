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
  Array $blocks = [],
) {

  $params = {
    proto  => 'tcp',
    dport  => [80, 443],
    state  => 'NEW',
    action => 'accept'
  }

  $blocks.flatten.each |$block| {
    firewall { "200 HTTP: ${block['name']}":
      source => $block['source'],
      *      => $params
    }
  }

  # for each node whose datacenter is NOT one of the block names, make a rule
  #  nodes_for_class('nebula::profile::haproxy').each |String $nodename| {
  #   $node_net = fact_for($nodename, 'networking')
  #    firewall { "200 HTTP: ${nodename}":
  #      source => $node_net['ip'],
  #      *      => $params
  #    }
  #  }
}
