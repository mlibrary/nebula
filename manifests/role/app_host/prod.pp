# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::app_host::prod
#
# Application host (production)
#
# @example
#   include nebula::role::app_host::prod
class nebula::role::app_host::prod {
  include nebula::profile::base
  include nebula::profile::dns::standard
  include nebula::profile::metricbeat
  include nebula::profile::ruby
}
