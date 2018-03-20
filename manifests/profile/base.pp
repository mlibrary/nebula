# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base
#
# Disable mcollective on all machines and hpwdt on HP machines.
#
# @example
#   include nebula::profile::base
class nebula::profile::base {
  include nebula::profile::base::stop_mcollective
  include nebula::profile::base::blacklist_hpwdt
}
