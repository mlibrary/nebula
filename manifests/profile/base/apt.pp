# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::apt
#
# Manage apt.
#
# @example
#   include nebula::profile::base::apt
class nebula::profile::base::apt (
  String $mirror,
) {
  # Ensure that apt knows to never ever install recommended packages
  # before it installs any packages.
  File['/etc/apt/apt.conf.d/99no-recommends'] -> Package<| |>

  # delete this after 2018-04-19
  cron { 'apt-get update':
    ensure  => 'absent',
    command => '/usr/bin/apt-get update -qq',
    hour    => '1',
    minute  => '0',
  }

  class { 'apt':
    purge => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences'    => true,
      'preferences.d'  => true,
    },
  }

  apt::source { 'main':
    location => $mirror,
    repos    => 'main contrib non-free',
  }

  apt::source { 'updates':
    location => $mirror,
    release  => "${::lsbdistcodename}-updates",
    repos    => 'main contrib non-free',
  }

  apt::source { 'security':
    release => "${::lsbdistcodename}/updates",
    repos   => 'main contrib non-free',
  }

  case $::lsbdistcodename {
    'jessie': {
      Apt::Source['security'] {
        location => 'http://security.debian.org/',
      }
    }

    default: {
      Apt::Source['security'] {
        location => 'http://security.debian.org/debian-security',
      }
    }
  }

  file { '/etc/apt/apt.conf.d/99no-recommends':
    content => template('nebula/profile/base/apt_no_recommends.erb'),
  }

  file { '/etc/apt/apt.conf.d/99force-ipv4':
    content => template('nebula/profile/base/apt_no_ipv6.erb'),
  }
}
