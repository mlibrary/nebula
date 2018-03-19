# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::hathi::prod
#
# HathiTrust production
#
# @example
#   include nebula::role::hathi::prod
class nebula::role::hathi::prod {
  include nebula::profile::base
  include nebula::profile::dns::smartconnect
  include nebula::profile::metricbeat
}
