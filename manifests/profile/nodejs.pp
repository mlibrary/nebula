# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::nodejs
#
# Install the LTS release of nodejs
#
# @example
#   include nebula::profile::nodejs
class nebula::profile::nodejs () {
  include nebula::profile::apt

    apt::source { 'nodesource.com':
      comment       => 'Nodesource apt source for recent nodejs',
      location      => 'https://deb.nodesource.com/node_10.x',
      release       => $facts['os']['distro']['codename'],
      repos         => 'main',
      notify_update => true,
      key           => {
        'id'     => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
        'source' => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
        'server' => 'keyserver.ubuntu.com',
      },
      include       => {
        'src' => false,
        'deb' => true,
    }
  }

  package { 'nodejs': }
}
