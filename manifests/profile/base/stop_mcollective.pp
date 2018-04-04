# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::stop_mcollective
#
# Disable mcollective on all machines.
#
# @example
#   include nebula::profile::base::stop_mcollective
class nebula::profile::base::stop_mcollective {
  service { 'mcollective':
    ensure => 'stopped',
    enable => false,
  }
}
