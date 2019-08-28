# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tsm
#
# Install TSM backup agent
#
# This does not automate entry of the node password or encryption key (if
# used); "dsmc" must still be run manually to configure that.

class nebula::profile::tsm (
) {
  package { 'tivsm-ba': }

  file { '/etc/init.d/tsm.service':
    source => 'puppet:///modules/nebula/tsm/tsm.service'
  }

  service { 'dsmcad':
    ensure => 'stopped',
    enable => false
  }

  service { 'tsm':
    enable => true
  }

}
