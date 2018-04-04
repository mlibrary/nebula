# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::sysctl
#
# Configure /etc/sysctl.conf
#
# @param bridge Whether to enable net.bridge settings
#
# @example
#   include nebula::profile::base::sysctl
class nebula::profile::base::sysctl (
  Boolean $bridge = false,
) {
  service { 'procps':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/sysctl.conf':
    content => template('nebula/profile/base/sysctl.conf.erb'),
    notify  => Service['procps'],
  }
}
