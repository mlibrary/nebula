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
          'id'     => '57446EFDE098E5C934B69C7DC208ADDE26C2B797',
          'source' => 'https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub',
        },
      }
    }
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

    # delete this after 2018-04-19
    cron { 'apt-get update':
      ensure  => 'absent',
      command => '/usr/bin/apt-get update -qq',
      hour    => '1',
      minute  => '0',
    }

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

      }
    }

    apt::source { 'adoptopenjdk':
      location => 'https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/',
      release  => $::lsbdistcodename,
      repos    => 'main',
      key      => {
        'id'     => '8ED17AF5D7E675EB3EE3BCE98AC3B29174885C03',
        'source' => 'https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public'
      }
    }

    apt::source { 'puppet':
      location => 'http://apt.puppetlabs.com',
      repos    => $puppet_repo,
      key      => {
        'id'     => 'D6811ED3ADEEB8441AF5AA8F4528B6CD9E61EF26',
        'source' => 'https://apt.puppetlabs.com/DEB-GPG-KEY-puppet-20250406'
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
