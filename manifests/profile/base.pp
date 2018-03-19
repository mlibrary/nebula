# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::base
#
# Disable mcollective on all machines and hpwdt on HP machines.
#
# @example
#   include nebula::base
class nebula::profile::base {
  service { 'mcollective':
    ensure => 'stopped',
    enable => false,
  }

  if $facts['dmi']['manufacturer'] == 'HP' {
    kmod::blacklist { 'hpwdt':
      file => '/etc/modprobe.d/kpwdt-blacklist.conf',
    }
  }
}
