# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::apt
#
# Manage apt.
#
# @example
#   include nebula::profile::base::apt
class nebula::profile::base::apt {
  # Ensure that apt knows to never ever install recommended packages
  # before it installs any packages.
  File['/etc/apt/apt.conf.d/99no-recommends'] -> Package<| |>

  cron { 'apt-get update':
    command => '/usr/bin/apt-get update -qq',
    hour    => '1',
    minute  => '0',
  }

  file { '/etc/apt/apt.conf.d/99no-recommends':
    content => template('nebula/profile/base/apt_no_recommends.erb'),
  }

  file { '/etc/apt/apt.conf.d/99force-ipv4':
    content => template('nebula/profile/base/apt_no_ipv6.erb'),
  }
}
