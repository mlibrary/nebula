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
  String $ubuntu_mirror = 'http://us.archive.ubuntu.com/ubuntu',
  Optional[Hash] $local_repo = undef,
) {

  if($::os['family'] == 'Debian') {
    package { 'aptitude': }

    # Ensure that apt knows to never ever install recommended packages
    # before it installs any packages.
    File['/etc/apt/apt.conf.d/99no-recommends'] -> Package<| |>

    # Ensure that apt repos are set up and updated before attempting to install a
    # new package. Tag some packages as 'preinstalled' to avoid dependency cycles.
    ensure_packages(['dirmngr'], {
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

    file { '/etc/apt/apt.conf.d/99no-recommends':
      content => template('nebula/profile/apt/apt_no_recommends.erb'),
    }

    file { '/etc/apt/apt.conf.d/99force-ipv4':
      content => template('nebula/profile/apt/apt_no_ipv6.erb'),
    }

    if $local_repo {
      apt::source { 'local':
        *            => $local_repo,
        release      => $::os['distro']['codename'],
        repos        => 'main',
        architecture => $::os['architecture'],
      }
    }

    if $facts['dmi'] and ($facts['dmi']['manufacturer'] == 'HP' or $facts['dmi']['manufacturer'] == 'HPE') {
      apt::source { 'hp':
        location => 'http://downloads.linux.hpe.com/SDR/repo/mcp/debian',
        release  => "${::os['distro']['codename']}/current",
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
        'name'   => 'puppetlabs.asc',
        'source' => 'puppet:///modules/nebula/apt/keyrings/puppetlabs.asc'
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

  if($::os['name'] == 'Debian') {
    # TODO: port to DEB822
    # TODO: remove non-free where we're not using it
    # TODO: remove branches when we're off buster, bullseye
    $repos = $::os['distro']['codename'] ? {
      'bookworm' => "main contrib non-free non-free-firmware",
      default    => "main contrib non-free",
    }
    apt::source { 'main':
      location => $mirror,
      repos    => $repos,
    }

    $security_release = $::os['distro']['codename'] ? {
      'buster'  => "${::os['distro']['codename']}/updates",
      default   => "${::os['distro']['codename']}-security",
    }

    apt::source { 'security':
      location => 'http://security.debian.org/debian-security',
      release  => $security_release,
      repos    => $repos,
    }

    unless empty($::installed_backports) {
      class { 'apt::backports':
        location => $mirror,
      }
    }

    apt::source { 'updates':
      location => $mirror,
      release  => "${::os['distro']['codename']}-updates",
      repos    => $repos,
    }

    apt::source { 'adoptium':
      location => 'https://packages.adoptium.net/artifactory/deb/',
      release  => $::os['distro']['codename'],
      repos    => 'main',
      key      => {
        'name'   => 'adoptium.asc',
        'source' => 'puppet:///modules/nebula/apt/keyrings/adoptium.asc',
      }
    }
  } elsif($::os['name'] == 'Ubuntu') {
    # port to DEB822 before upgrade to 24.04
    apt::source {
      default:
        location => $ubuntu_mirror,
        repos    => 'main restricted universe',
      ;
      'main'     : release => $::os['distro']['codename'];
      'updates'  : release => "${::os['distro']['codename']}-updates";
      'backports': release => "${::os['distro']['codename']}-backports";
      'security' : release => "${::os['distro']['codename']}-security";
    }

    package { 'landscape-common': ensure => purged }
    package { 'open-vm-tools': ensure => purged }
    file { '/etc/apt/apt.conf.d/20apt-esm-hook.conf': ensure => absent }
  }
}
