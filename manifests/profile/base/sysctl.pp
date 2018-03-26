# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::sysctl
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include nebula::profile::base::sysctl
class nebula::profile::base::sysctl (
  Boolean $bridge = false,
) {
  file { '/etc/sysctl.conf':
    content => template('nebula/profile/base/sysctl.conf.erb'),
  }
}
