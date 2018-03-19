# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::hathi::prep_app_host
#
# HathiTrust prep application host
#
# @example
#   include nebula::role::hathi::prep_app_host
class nebula::role::hathi::prep_app_host {
  include nebula::profile::base
  include nebula::profile::dns::smartconnect
  include nebula::profile::metricbeat
  include nebula::profile::ruby
}
