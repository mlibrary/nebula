# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Prometheus for hardware monitoring
class nebula::role::prometheus {
  include nebula::role::umich

  @nebula::taghosts::tag { 'prom': }
  include nebula::profile::ntp
  include nebula::profile::prometheus
}
