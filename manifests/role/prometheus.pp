# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Prometheus for hardware monitoring
class nebula::role::prometheus ()
{
  include nebula::role::minimal_docker
  include nebula::profile::ntp
  include nebula::profile::prometheus
}
