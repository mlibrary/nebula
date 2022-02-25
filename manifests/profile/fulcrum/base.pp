# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.


# Base profile for a Fulcrum host; sets up networking and app user.
class nebula::profile::fulcrum::base (
  $uid = 717,
  $gid = 717,
) {
  ensure_packages([
    'sudo',
  ])

  host { 'localhost':
    ip           => '127.0.0.1',
  }

  host { $::hostname:
    host_aliases => [$::fqdn],
    ip           => $::ipaddress,
  }

  host { 'ip6-localhost':
    host_aliases => ['localhost', 'ip6-loopback'],
    ip           => '::1',
  }

  host { 'ip6-allnodes':
    ip => 'ff02::1',
  }

  host { 'ip6-allrouters':
    ip => 'ff02::2',
  }

  group { 'fulcrum':
    gid => $gid,
  }

  user { 'fulcrum':
    comment    => 'Fulcrum Application User',
    uid        => $uid,
    gid        => $gid,
    home       => '/home/fulcrum',
    shell      => '/bin/bash',
    managehome => true,
    require    => Group['fulcrum'],
  }

  file { '/var/local/fulcrum':
    ensure  => directory,
    owner   => 'fulcrum',
    group   => 'fulcrum',
    require => User['fulcrum'],
  }
}
