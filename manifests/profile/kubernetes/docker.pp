# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::docker {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $docker_version = $cluster['docker_version']

  if $docker_version == undef {
    fail('You must set a specific docker version')
  }

  class { 'nebula::profile::docker':
    version                => $docker_version,
    docker_compose_version => '',
  }
}
