# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Puppet Master
#
# @example
#   include nebula::role::puppet::master
class nebula::role::puppet::master {
  include nebula::role::umich
  include nebula::profile::puppet::master
  include nebula::profile::puppet::master_with_db
}
