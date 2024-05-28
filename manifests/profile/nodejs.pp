# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::nodejs
#
# Install the LTS release of nodejs
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
  $version = '10',
) {
  include nebula::profile::apt

    apt::source { 'nodesource.com':
      comment       => 'Nodesource apt source for recent nodejs',
      location      => "https://deb.nodesource.com/node_${version}.x",
      release       => $::lsbdistcodename,
      repos         => 'main',
      notify_update => true,
      key           => {
        'name'   => 'nodesource.asc',
        'source' => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
      },
      include       => {
        'src' => false,
        'deb' => true,
    }
  }

  package { 'nodejs': }
}
