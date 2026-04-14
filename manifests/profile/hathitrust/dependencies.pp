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
      'emacs',
      'geoip-bin',
      'git',
      'grokj2k',
      'libjs-jquery',
      'libxerces-c-samples',
      'netpbm',
      'rsync',
      'unzip',
      'zip',
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
    target => '/htapps/babel/geoip'
  }

  package {
    'jhove':
  }

  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/kdu_munge':
    ensure => 'file',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/kdu_munge"
  }

  package {
    [
      'default-jre-headless',
      'lftp',
    ]:
  }

  ensure_packages(['mariadb-client'])
}
