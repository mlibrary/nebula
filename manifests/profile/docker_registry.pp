# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Docker Registry
#
# This creates an unsecured docker registry with no authentication. It's
# accessible via port 5000, which is opened to servers in our
# datacenters. Persistent registry data is stored in /docker-registry.
class nebula::profile::docker_registry (
  String $storage_volume,
) {
  require nebula::profile::docker

  # Until we implement some manner of authentication, this should remain
  # only open to our own servers. If we ever want developers to be able
  # to push their own images, this will need revisiting.
  nebula::exposed_port { '200 Docker Registry':
    port  => 5000,
    block => 'umich::networks::datacenter',
  }

  docker::run { 'registry':
    image   => 'registry:2',
    ports   => '5000:5000',
    volumes => '/docker-registry:/var/lib/registry',
    require => Nebula::Nfs_mount['/docker-registry'],
  }

  nebula::nfs_mount { '/docker-registry':
    remote_target => $storage_volume,
  }
}
