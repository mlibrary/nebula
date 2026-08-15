# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking
#
# Configure networking
#
# @param bridge Whether to enable net.bridge settings
# @param keytab Whether to install and use keytabs, which are
#   further configured via hiera
#
# @example
#   include nebula::profile::networking

class nebula::profile::networking (
  Boolean $bridge = false,
) {
  class { 'nebula::profile::networking::sysctl':
    bridge => $bridge,
  }

  include nebula::profile::networking::sshd
}
