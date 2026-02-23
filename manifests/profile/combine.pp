# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Profile for a server running the Combine metadata harvester
class nebula::profile::combine {
  file { '/etc/sysctl.d/combine.conf':
    content => template('nebula/profile/combine/sysctl.conf.erb'),
  }
}

