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
  Optional[Hash] $repos = undef,
) {
  if($facts['os']['family'] == 'Debian') {
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

    if $repos {
      $repo_defaults = {
        release      => $facts['os']['distro']['codename'],
        repos        => 'main',
        architecture => $facts['os']['architecture'],
      }
      create_resources(apt::source,$repos,$repo_defaults)
    }

    if $facts['dmi'] and ($facts['dmi']['manufacturer'] == 'HP' or $facts['dmi']['manufacturer'] == 'HPE') {
      # `hpe1` is deprecated, but as of this writing is still used to sign HPE's Debian repos.
      # At some point in 2025 this key should stop working, at which point we can move Debian
      # to hpe2 as well. Due to an apparent bug in apt, hpe2 does not work when armored, so
      # it has been included in this repo as a dearmored binary key.
      # See also: https://downloads.linux.hpe.com/SDR/keys.html
      $hpe_key = $facts['os']['distro']['codename'] ? {
        'bullseye' => 'hpe1.gpg',
        default => 'hpe2.gpg',
      }

      apt::source { 'hpe':
        source_format => 'sources',
        location      => ['https://downloads.linux.hpe.com/SDR/repo/mcp'],
        release       => "${facts['os']['distro']['codename']}/current",
        repos         => ['non-free'],
        keyring       => "/etc/apt/keyrings/${hpe_key}",
      }

      apt::keyring { $hpe_key:
        source => "puppet:///modules/nebula/apt/keyrings/${hpe_key}",
      }
    }

    apt::source { 'openvox':
      source_format => 'sources',
      location      => ['https://apt.voxpupuli.org'],
      release       => "${facts['os']['name'].downcase()}${facts['os']['release']['major']}",
      repos         => [$puppet_repo],
      keyring       => '/etc/apt/keyrings/openvox.asc',
      architecture  => $facts['os']['architecture'],
    }

    apt::keyring { 'openvox.asc':
      source => 'puppet:///modules/nebula/apt/keyrings/openvox.asc',
    }

    # replaced by /etc/apt/keyrings/puppetlabs.gpg, but still automatically created on new vms
    # remove this once vm creation no longer adds these files
    tidy { '/etc/apt/trusted.gpg.d/':
      recurse => true,
      matches => ['puppet*.gpg'],
    }

    # not used for os packages, and all added repos should use /etc/apt/keyrings
    file { '/etc/apt/trusted.gpg': ensure => absent }
  }

  if($facts['os']['name'] == 'Debian') {
    # TODO: remove non-free where we're not using it
    # TODO: remove branch when we're off bullseye
    $debian_repos = $facts['os']['distro']['codename'] ? {
      'bullseye' => ['main', 'contrib', 'non-free'],
      default    => ['main', 'contrib', 'non-free', 'non-free-firmware'],
    }

    apt::source {
      default:
        source_format => 'sources',
        location      => [$mirror],
        repos         => $debian_repos,
        keyring       => '/usr/share/keyrings/debian-archive-keyring.gpg',
      ;
      'main': ;
      'security':
        release  => "${facts['os']['distro']['codename']}-security",
        location => ['http://security.debian.org/debian-security'],
      ;
      # remove updates?
      'updates'  : release => "${facts['os']['distro']['codename']}-updates";
    }

    unless empty($facts['installed_backports']) {
      class { 'apt::backports':
        location => $mirror,
      }
    }

    apt::source { 'adoptium':
      source_format => 'sources',
      location      => ['https://packages.adoptium.net/artifactory/deb/'],
      release       => $facts['os']['distro']['codename'],
      repos         => ['main'],
      keyring       => '/etc/apt/keyrings/adoptium.asc',
    }

    apt::keyring { 'adoptium.asc':
      source => 'puppet:///modules/nebula/apt/keyrings/adoptium.asc',
    }
  } elsif($facts['os']['name'] == 'Ubuntu') {
    apt::source {
      default:
        source_format => 'sources',
        location      => [$ubuntu_mirror],
        repos         => ['main', 'restricted', 'universe'],
        keyring       => '/usr/share/keyrings/ubuntu-archive-keyring.gpg',
      ;
      'main'     : release => $facts['os']['distro']['codename'];
      'security' : release => "${facts['os']['distro']['codename']}-security";
      # remove updates and backports?
      'updates'  : release => "${facts['os']['distro']['codename']}-updates";
      'backports': release => "${facts['os']['distro']['codename']}-backports";
    }

    # remove unwanted recommends from `ubuntu-server` package
    package { 'landscape-common': ensure => purged }
    package { 'open-vm-tools': ensure => purged }

    # disable ubuntu subscription advertisements
    exec { 'disable 20apt-esm-hook.conf':
      creates => '/etc/apt/apt.conf.d/20apt-esm-hook.conf.disabled',
      timeout => 30,
      command => "/usr/bin/dpkg-divert --rename \
--divert /etc/apt/apt.conf.d/20apt-esm-hook.conf.disabled \
--add /etc/apt/apt.conf.d/20apt-esm-hook.conf"
    }
  }
}
