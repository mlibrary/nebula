# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::nodejs
#
# Install nodejs
#
# Don't expect default version to remain static. Use an explicit version
# when calling this class if you don't want it upgraded.
#
# @param version The major version of Node.js to install, e.g., 14.
#   This is used to select the version-specific repository, e.g., node_14.x
#
# @example
#   include nebula::profile::nodejs
#
# @example
#   class { 'nebula::profile::nodejs':
#     version => '14',
#   }
class nebula::profile::nodejs (
  Integer $version = 22,
) {
  include nebula::profile::apt

  class { 'nebula::profile::apt::nodejs':
    version => $version,
  }

  package { 'nodejs':
    require => Class['nebula::profile::apt::nodejs'],
  }
}
