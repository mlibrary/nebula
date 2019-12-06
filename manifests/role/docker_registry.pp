# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# See nebula::profile::docker_registry for details.
class nebula::role::docker_registry ()
{
  include nebula::role::minimal_docker
  include nebula::profile::docker_registry
}
