# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::consul::client {
  package { 'consul':
    require => Apt::Source['hashicorp'],
  }

  apt::source { 'hashicorp':
    location => 'https://apt.releases.hashicorp.com',
    release  => $facts['os']['distro']['codename'],
    key      => {
      'id'     => 'E8A032E094D8EB4EA189D270DA418C88A3219F7B',
      'source' => 'https://apt.releases.hashicorp.com/gpg',
    },
  }

  nebula::exposed_port {
    default:
      block => 'umich::networks::private_lan',
    ;

    '020 Consul LAN Serf (tcp)':
      port => 8301,
    ;

    '020 Consul LAN Serf (udp)':
      port     => 8301,
      protocol => 'udp',
    ;

    '020 Consul Sidecar Proxy':
      port => '21000-21255',
    ;
  }
}
