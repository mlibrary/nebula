# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::dependencies
#
# Install miscellaneous package dependencies for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::dependencies::ingest_indexing
class nebula::profile::hathitrust::dependencies::ingest_indexing () {

  # install jhove, pin it to buster if we're on stretch
  $package = 'jhove'
  if $facts['os']['release']['major'] == '9' {
    include nebula::profile::apt::testing
    $release = 'buster'
    apt::pin { "${release}-${package}":
      explanation => "Prioritze ${package} from ${release}",
      codename    => $release,
      priority    => 700,
      packages    => [$package],
      require     => Class['nebula::profile::apt::testing']
    }

    package {
      $package:
      require => Apt::Pin["${release}-${package}"]
    }
  }
  else {
    package {
      $package:
    }
  }

  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/kdu_munge':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/kdu_munge"
  }

  package {
    'openjdk-8-jdk-headless':
  }

}
