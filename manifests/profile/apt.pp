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
  Boolean $purge = true,
  Optional[Hash] $local_repo = undef,
) {

  if($facts['os']['family'] == 'Debian') {
    if $local_repo {
      apt::source { 'local':
        *            => $local_repo,
        release      => $::lsbdistcodename,
        repos        => 'main',
        architecture => $::os['architecture'],
      }
    }

    if $facts['dmi'] and ($facts['dmi']['manufacturer'] == 'HP' or $facts['dmi']['manufacturer'] == 'HPE') {
      apt::source { 'hp':
        location => 'http://downloads.linux.hpe.com/SDR/repo/mcp/debian',
        release  => "${::lsbdistcodename}/current",
        repos    => 'non-free',
        key      => {
          'name'   => 'hpe.asc',
          'source' => 'https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub',
        },
      }
    }

    apt::source { 'puppet':
      location => 'http://apt.puppetlabs.com',
      repos    => $puppet_repo,
      key      => {
        'name'   => 'puppetlabs.gpg',
        'source' => 'https://apt.puppetlabs.com/keyring.gpg'
      }
    }

    # replaced by /etc/apt/keyrings/puppetlabs.gpg, but still automatically created on new vms
    # remove this once vm creation no longer adds these files
    tidy { '/etc/apt/trusted.gpg.d/':
      recurse => true,
      matches => [ 'puppet*.gpg' ],
    }

    # not used for os packages, and all added repos should use /etc/apt/keyrings
    file { '/etc/apt/trusted.gpg': ensure => absent }
  }

  if($::operatingsystem == 'Debian') {
    # Ensure that apt knows to never ever install recommended packages
    # before it installs any packages.
    File['/etc/apt/apt.conf.d/99no-recommends'] -> Package<| |>

    # Ensure that apt repos are set up and updated before attempting to install a
    # new package. Tag some packages as 'preinstalled' to avoid dependency cycles.
    ensure_packages(['apt-transport-https','dirmngr'], {
      tag => 'package-preinstalled'
    })

    Apt::Source <| |> -> Package <| tag != 'package-preinstalled' |>
    Class['apt::update'] -> Package <| |>

    class { 'apt':
      purge  => {
        'sources.list'   => $purge,
        'sources.list.d' => $purge,
        'preferences'    => $purge,
        'preferences.d'  => $purge,
      },
      update => {
        frequency => 'daily',
      },
    }

    apt::source { 'main':
      location => $mirror,
      repos    => 'main contrib non-free',
    }

    $security_release = $::lsbdistcodename ? {
      'buster'  => "${::lsbdistcodename}/updates",
      default   => "${::lsbdistcodename}-security",
    }

    apt::source { 'security':
      location => 'http://security.debian.org/debian-security',
      release  => $security_release,
      repos    => 'main contrib non-free',
    }

    unless empty($::installed_backports) {
      class { 'apt::backports':
        location => $mirror,
      }
    }

    apt::source { 'updates':
      location => $mirror,
      release  => "${::lsbdistcodename}-updates",
      repos    => 'main contrib non-free',
    }

    apt::source { 'adoptium':
      location => 'https://packages.adoptium.net/artifactory/deb/',
      release  => $::lsbdistcodename,
      repos    => 'main',
      key      => {
        'name'   => 'adoptium.asc',
        'source' => 'https://packages.adoptium.net/artifactory/api/gpg/key/public'
      }
    }

    file { '/etc/apt/apt.conf.d/99no-recommends':
      content => template('nebula/profile/apt/apt_no_recommends.erb'),
    }

    file { '/etc/apt/apt.conf.d/99force-ipv4':
      content => template('nebula/profile/apt/apt_no_ipv6.erb'),
    }
  }
}
