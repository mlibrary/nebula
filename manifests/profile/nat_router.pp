# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::nat_router (
  String $lan_cidr,
  String $public_ip_address,
) {
  include nebula::profile::networking::sysctl

  file { '/etc/sysctl.d/router.conf':
    content => template('nebula/profile/nat_router/sysctl.conf.erb'),
    notify  => Service['procps'],
  }

  firewall {
    default:
      table  => 'nat',
      chain  => 'POSTROUTING',
      proto  => 'all',
      source => $lan_cidr,
    ;

    '001 leave internal requests alone':
      jump        => 'accept',
      destination => $lan_cidr,
    ;

    '002 translate the source address on external requests':
      jump     => 'SNAT',
      tosource => $public_ip_address,
    ;
  }
}
