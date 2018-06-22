# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::load_balancer
#
# Load balance aka haproxy server
#
# @example
#   include nebula::role::load_balancer
class nebula::role::load_balancer {
  include nebula::role::umich
  include nebula::profile::haproxy::keepalived
}
