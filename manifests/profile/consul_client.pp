# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::consul_client (
  String $organization,
) {
  package { 'consul':
    require => Apt::Source['hashicorp'],
  }

  apt::source { 'hashicorp':
    location => 'https://apt.releases.hashicorp.com',
    release  => fact('os.distro.codename'),
    repos    => 'main',
    key      => {
      'id'     => 'E8A032E094D8EB4EA189D270DA418C88A3219F7B',
      'source' => 'https://apt.releases.hashicorp.com/gpg',
    },
  }

  Firewall <<| tag == "${::datacenter}_${organization}_consul_lan_gossip" |>>

  @@firewall {
    default:
      source => $::ipaddress,
      state  => 'NEW',
      action => 'accept',
    ;;

    "Consul LAN RPC ${::hostname}":
      tag   => "${::datacenter}_${organization}_consul_lan_rpc",
      dport => 8300,
      proto => 'tcp',
    ;;

    "Consul LAN TCP gossip ${::hostname}":
      tag   => "${::datacenter}_${organization}_consul_lan_gossip",
      dport => 8301,
      proto => 'tcp',
    ;;

    "Consul LAN UDP gossip ${::hostname}":
      tag   => "${::datacenter}_${organization}_consul_lan_gossip",
      dport => 8301,
      proto => 'udp',
    ;;
  }
}
