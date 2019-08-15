# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::app_host::dev_private
#
# Application host (development or development-like, with private network configured).
#
# Be sure to set the networking::private details for the host in hiera.
#
# @example
#   include nebula::role::app_host::prod_private
class nebula::role::app_host::dev_private {
  include nebula::role::app_host::dev
  include nebula::profile::networking::private
}
