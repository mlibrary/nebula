# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::gateway {
  include nebula::role::umich
  include nebula::profile::haproxy
  include nebula::profile::nat_router
}
