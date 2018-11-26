# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::log_host
#
# Fauxpaas server
#
# @example
#   include nebula::role::log_host
class nebula::role::log_host {
  include nebula::role::umich
  include nebula::profile::ruby
}
