# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::router {
  include nebula::profile::networking::sysctl

  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $node_cidr = pick($cluster['node_cidr'], lookup('nebula::profile::kubernetes::node_cidr'))
  $public_address = $cluster['public_address']
  $private_address = $cluster['private_address']
  $private_cidr = $cluster['private_cidr']

  file { '/etc/sysctl.d/router.conf':
    content => template('nebula/profile/kubernetes/router/sysctl.conf.erb'),
    notify  => Service['procps'],
  }

  firewall { '001 Do not NAT internal requests':
    table       => 'nat',
    chain       => 'POSTROUTING',
    jump        => 'accept',
    proto       => 'all',
    source      => $node_cidr,
    destination => $node_cidr,
  }

  if $private_address != undef {
    firewall { '002 Give internal requests our private IP':
      table       => 'nat',
      chain       => 'POSTROUTING',
      jump        => 'SNAT',
      proto       => 'all',
      source      => $node_cidr,
      tosource    => $private_address,
      destination => $private_cidr,
    }
  }

  firewall { '003 Give external requests our public IP':
    table    => 'nat',
    chain    => 'POSTROUTING',
    jump     => 'SNAT',
    proto    => 'all',
    source   => $node_cidr,
    tosource => $public_address,
  }
}
