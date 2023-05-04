# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::app_host::prod_private_java
#
# Application host (production or production-like, with private network configured).
#
# Be sure to set the networking::private details for the host in hiera.
#
# @example
#   include nebula::role::app_host::prod_private
class nebula::role::app_host::prod_private_java {
  include nebula::role::app_host::prod_private
  include nebula::profile::openjdk_java
}
