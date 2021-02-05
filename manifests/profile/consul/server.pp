# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::consul::server {
  include nebula::profile::consul::client

  nebula::exposed_port {
    default:
      block => 'umich::networks::private_lan',
    ;

    '020 Consul DNS (tcp)':
      port => 8600,
    ;

    '020 Consul DNS (udp)':
      port     => 8600,
      protocol => 'udp',
    ;

    '020 Consul HTTP':
      port => 8500,
    ;

    '020 Consul Server RPC':
      port => 8300,
    ;
  }
}
