# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::hathi::dev
#
# HathiTrust development
#
# @example
#   include nebula::role::hathi::dev
class nebula::role::hathi::dev {
  include nebula::profile::base
  include nebula::profile::dns::smartconnect
  include nebula::profile::metricbeat
}
