# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::app_host::dev
#
# Application host (development)
#
# @example
#   include nebula::role::app_host::dev
class nebula::role::app_host::dev {
  include nebula::role::umich
  include nebula::profile::ruby
}
