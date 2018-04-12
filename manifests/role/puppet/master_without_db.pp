# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Puppet Master
#
# @example
#   include nebula::role::puppet::master_without_db
class nebula::role::puppet::master_without_db {
  include nebula::role::umich
  include nebula::profile::puppet::master
}
