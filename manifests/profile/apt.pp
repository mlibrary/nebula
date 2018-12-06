# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apt
#
# Manage apt.
#
# @example
#   include nebula::profile::apt
class nebula::profile::apt (
  String $mirror,
  String $puppet_repo,
  Optional[Hash] $local_repo = undef,
) {



  # Run an initial apt update if the main package list is missing, primarily so
  # that we can install apt-transport-https

  # Remove initial http(s); replace / with _; add trailing _ if needed
  $cache_mirror_prefix = $mirror.regsubst('^https?://','').regsubst('/','_','G').regsubst('([^_])$',"${1}_")
  exec { 'initial apt update':
    command => '/usr/bin/apt-get update',
    creates => "/var/lib/apt/lists/${cache_mirror_prefix}dists_${::lsbdistcodename}_main_binary-${::architecture}_Packages"
  }


  # Ensure that apt knows to never ever install recommended packages
  # before it installs any packages.
  File['/etc/apt/apt.conf.d/99no-recommends'] -> Package<| |>

  # Ensure that apt repos are set up and updated before attempting to install a
  # new package, except for apt-transport-https, as that package is required to
  # update some of the repositories.
  Apt::Source <| |> -> Package <| title != 'apt-transport-https' |>
  Class['apt::update'] -> Package <| title != 'apt-transport-https' |>

  # delete this after 2018-04-19
  cron { 'apt-get update':
    ensure  => 'absent',
    command => '/usr/bin/apt-get update -qq',
    hour    => '1',
    minute  => '0',
  }

  class { 'apt':
    purge  => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences'    => true,
      'preferences.d'  => true,
    },
    update => {
      frequency => 'daily',
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

  package { 'apt-transport-https': }

  if $local_repo {
    apt::source { 'local':
      *       => $local_repo,
      release => $::lsbdistcodename,
      repos   => 'main',
      require => Package['apt-transport-https']
    }
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

  apt::source { 'puppet':
    location => 'http://apt.puppetlabs.com',
    repos    => $puppet_repo,
  }

  unless empty($::installed_backports) {
    class { 'apt::backports':
      location => $mirror,
    }
  }

  if $facts['dmi'] and $facts['dmi']['manufacturer'] == 'HP' {
    apt::source { 'hp':
      location => 'http://downloads.linux.hpe.com/SDR/repo/mcp/debian',
      release  => "${::lsbdistcodename}/current",
      repos    => 'non-free',
    }
  }

  file { '/etc/apt/apt.conf.d/99no-recommends':
    content => template('nebula/profile/apt/apt_no_recommends.erb'),
  }

  file { '/etc/apt/apt.conf.d/99force-ipv4':
    content => template('nebula/profile/apt/apt_no_ipv6.erb'),
  }
}
