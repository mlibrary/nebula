# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::consul_server {
  include nebula::role::minimum
  include nebula::profile::consul_client

  $organization = lookup('nebula::profile::consul_client::organization')

  Firewall <<| tag == "${::datacenter}_${organization}_consul_lan_rpc" |>>
  Firewall <<| tag == "${organization}_consul_wan_rpc" |>>

  @@firewall {
    default:
      source => $::ipaddress,
      state  => 'NEW',
      action => 'accept',
    ;;

    "Consul WAN RPC ${::hostname}":
      tag   => "${organization}_consul_wan_rpc",
      dport => 8300,
      proto => 'tcp',
    ;;

    "Consul WAN TCP gossip ${::hostname}":
      tag   => "${organization}_consul_wan_gossip",
      dport => 8302,
      proto => 'tcp',
    ;;

    "Consul WAN UDP gossip ${::hostname}":
      tag   => "${organization}_consul_wan_gossip",
      dport => 8302,
      proto => 'udp',
    ;;
  }
}
