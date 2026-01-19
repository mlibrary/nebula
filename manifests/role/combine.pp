# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Role for hosting the Combine metadata application
#
# @example
#   include nebula::role::combine
class nebula::role::combine (
  Integer $port = 8080,
) {
  include nebula::role::umich
  class { 'nebula::profile::https_to_port':
    port => $port,
  }

}

