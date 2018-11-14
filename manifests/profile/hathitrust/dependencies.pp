# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::dependencies
#
# Install miscellaneous package dependencies for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::dependencies
class nebula::profile::hathitrust::dependencies () {
  package {
    [
      'git',
      'imagemagick',
      'libjs-jquery',
      'libxerces-c-samples',
      'unzip',
      'zip',
      'netpbm-sf',
      'kakadu'
    ]:
  }

  file { ['/l/local','/l/local/bin']:
    ensure => 'directory'
  }

  ['unzip','kdu_expand'].each |String $binary|  {
    file { "/l/local/bin/${binary}":
      ensure => 'link',
      target => "/usr/bin/${binary}"
    }
  }


}
