# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::hathi::prep
#
# HathiTrust prep
#
# @example
#   include nebula::role::hathi::prep
class nebula::role::hathi::prep {
  include nebula::profile::base
  include nebula::profile::dns::smartconnect
  include nebula::profile::metricbeat
}
