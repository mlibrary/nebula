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
      'awscli',
      'geoip-bin',
      'git',
      'kakadu',
      'libjs-jquery',
      'libxerces-c-samples',
      'netpbm-sf',
      'rsync',
      'unzip',
      'zip'
    ]
  )

  file { '/l':
    ensure => 'directory'
  }


  file { '/l/local':
    ensure => 'directory'
  }

  file { '/l/local/bin':
    ensure => 'symlink',
    target => '/usr/bin'
  }

  file { '/usr/share/GeoIP':
    target =>  '/htapps/babel/geoip'
  }

  # install jhove, pin it to buster if we're on stretch
  if $facts['os']['family'] == 'Debian' and $::lsbdistcodename == 'stretch' {
    include nebula::profile::apt::buster
    include apt::backports

    $packages = ['jhove','libjaxb-api-java','libactivation-java']
    $release = 'buster'

    apt::pin { "${release}-jhove":
      explanation => "Prioritize ${packages} from ${release}",
      codename    => $release,
      priority    => 700,
      packages    => $packages,
      require     => Class['nebula::profile::apt::buster']
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
    ]:
  }

  if $::lsbdistcodename == 'stretch' {
    ensure_packages(['mariadb-client-10.1'])
  } elsif $::lsbdistcodename == 'bullseye' {
    ensure_packages(['mariadb-client'])
  }

}
