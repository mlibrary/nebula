# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::default
#
# Minimal server
#
# @example
#   include nebula::role::default
class nebula::role::default {
  include nebula::profile::base
  include nebula::profile::dns::standard
  include nebula::profile::metricbeat
}
