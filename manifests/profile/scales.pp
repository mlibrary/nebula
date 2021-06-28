# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::scales
#
# Profile for clearinghouse scales server.
#
# @example
#   include nebula::profile::scales
class nebula::profile::scales (
) {
  nebula::usergroup { 'clearinghouse': }

  nebula::exposed_port { '100 SSH Umich VPN':
    port  => 22,
    block => 'umich::networks::umich_vpn',
  }

  package {
    [ 'git', 'python3-venv', 'python3-pip',
      'python3-setuptools', 'python3-wheel', ]:
  }
}
