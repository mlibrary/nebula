# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Puppet Master
#
# @example
#   include nebula::role::puppet::master
class nebula::role::puppet::master {
  include nebula::profile::base
  include nebula::profile::dns::standard
  include nebula::profile::metricbeat
  include nebula::profile::puppet::master
}
