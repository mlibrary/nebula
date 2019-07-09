# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::dependencies
#
# Install miscellaneous package dependencies for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::dependencies
class nebula::profile::hathitrust::dependencies () {
  include nebula::profile::imagemagick

  ensure_packages (
    [
      'git',
      'libjs-jquery',
      'libxerces-c-samples',
      'unzip',
      'zip',
      'netpbm-sf',
      'kakadu',
      'rsync'
    ]
  )

  file { '/l/local':
    ensure => 'directory'
  }

  file { '/l/local/bin':
    ensure => 'symlink',
    target => '/usr/bin'
  }

  # install jhove, pin it to buster if we're on stretch
  if $facts['os']['family'] == 'Debian' and $facts['os']['family']['distro']['codename'] != 'jessie' {
    include nebula::profile::apt::testing
    include apt::backports

    $packages = ['jhove','libjaxb-api-java','libactivation-java']
    $release = 'buster'

    apt::pin { "${release}-jhove":
      explanation => "Prioritize ${packages} from ${release}",
      codename    => $release,
      priority    => 700,
      packages    => $packages,
      require     => Class['nebula::profile::apt::testing']
    }

    package {
      $packages:
      require => Apt::Pin["${release}-jhove"]
    }
  }
  else {
    package {
      'jhove':
    }
  }

  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/kdu_munge':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/kdu_munge"
  }

  package {
    [
      'openjdk-11-jdk-headless',
      'lftp',
      'mariadb-client-10.1'
    ]:
  }

}
