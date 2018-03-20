# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::blacklist_hpwdt
#
# Blacklist hpwdt on all HP machines.
#
# @example
#   include nebula::profile::base::blacklist_hpwdt
class nebula::profile::base::blacklist_hpwdt {
  if $facts['dmi']['manufacturer'] == 'HP' {
    kmod::blacklist { 'hpwdt':
      file => '/etc/modprobe.d/kpwdt-blacklist.conf',
    }
  }
}
