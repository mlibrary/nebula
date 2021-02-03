# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::gateway::backup {
  include nebula::role::minimum

  include nebula::profile::nat_router
  include nebula::profile::keepalived::backup
}