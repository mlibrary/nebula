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

  $datacenters = $networks.flatten.map |$network| { $network['datacenter'] }.sort.unique

  $other_dc_nodes_query = ['from','facts',
    ['extract', ['certname','value'],
      ['and',
        ['=','name','ipaddress'],
        ['in','certname',
          ['extract', ['certname'], ['select_facts',
            ['and',
              ['=','name','datacenter'],
              ['not', ['in','value',
              ['array', $datacenters]]]]]]]]]]

  puppetdb_query($other_dc_nodes_query).each |$node| {
    firewall { "200 HTTP: ${node['certname']}":
      source => $node['value'],
      *      => $params
    }
  }
}
