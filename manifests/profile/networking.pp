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

  # Fix AEIM-1064. This prevents `systemctl is-active` from returning
  # a false negative when either of these is unmasked.
  #
  # To tell whether it's safe to remove this, try running the
  # following:
  #
  #     systemctl unmask procps
  #     systemctl unmask sshd
  #     systemctl is-active procps \
  #       && systemctl is-active sshd \
  #       && echo "AEIM-1064 no longer applies; get rid of the fix" \
  #       || echo "AEIM-1064 still applies; leave the ugly hack alone"
  exec { default:
    subscribe   => Service['procps', 'sshd'],
    refreshonly => true,
    ;
    '/bin/systemctl status procps':;
    '/bin/systemctl status sshd':;
  }
}
