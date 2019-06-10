# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::hp
#
# Customizations specific to physical HP/HPE machines
#
# @example
#   include nebula::profile::base::hp
class nebula::profile::base::hp {
  kmod::blacklist { 'hpwdt':
    file =>  '/etc/modprobe.d/kpwdt-blacklist.conf',
  }

  package { 'ssacli': }
}
