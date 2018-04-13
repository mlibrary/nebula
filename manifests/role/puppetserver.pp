# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::puppetserver
#
# Puppet server
#
# @example
#   include nebula::role::puppetserver
class nebula::role::puppetserver {
  include nebula::role::sysadmin_box
  include nebula::profile::puppet::mgmt
}
