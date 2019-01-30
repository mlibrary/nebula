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
  if $facts['os']['release']['major'] == '9' {
    include nebula::profile::apt::testing
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
      'openjdk-8-jdk-headless',
      'lftp',
      'mariadb-client-10.1'
    ]:
  }

}
