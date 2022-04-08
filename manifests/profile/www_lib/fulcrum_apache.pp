# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::fulcrum_apache
#
# Apache config and surrounding setup required to be a fulcrum.org web server.
# Note that this is different than a web server fully able to run an instance
# of Fulcrum. This profile includes all of the official domains and redirects
# for Fulcrum-the-service.
class nebula::profile::www_lib::fulcrum_apache (
) {
  @nebula::apache::ssl_keypair { 'fulcrum.org': }

  include nebula::profile::www_lib::vhosts::fulcrum

  nebula::apache::redirect_vhost_https { 'northwestern.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/northwestern',
    serveraliases => ['northwestern.fulcrum.org', 'northwestern.fulcrumservices.org'],
  }

  nebula::apache::redirect_vhost_https { 'minnesota.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/minnesota',
    serveraliases => [ 'minnesota.fulcrum.org', 'minnesota.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'michigan.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/michigan',
    serveraliases => [ 'michigan.fulcrum.org', 'michigan.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'indiana.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/indiana',
    serveraliases => [ 'indiana.fulcrum.org', 'indiana.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'pennstate.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/pennstate',
    serveraliases => [ 'pennstate.fulcrum.org', 'pennstate.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'nyupress.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/nyupress',
    serveraliases => [ 'nyupress.fulcrum.org', 'nyupress.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'dialogue.fulcrumscholar.org':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/dialogue',
    serveraliases => [ 'dialogue.fulcrum.org', 'dialogue.fulcrumservices.org']
  }

  nebula::apache::redirect_vhost_https { 'fulcrum.www.lib.umich.edu':
    ssl_cn        => 'fulcrum.org',
    priority      => '08',
    target        => 'https://www.fulcrum.org/',
    serveraliases => ['fulcrum.lib.umich.edu']
  }

  nebula::apache::redirect_vhost_https { 'fulcrum.org':
    priority      => '14',
    serveraliases => [
      'fulcrum.pub',
      'fulcrumscholar.org',
      'fulcrumscholar.com',
      'fulcrumscholar.net',
      'fulcrumservices.org',
      'fulcrumservices.net',
      '*.fulcrum.org',
      '*.fulcrum.pub',
      '*.fulcrumscholar.org',
      '*.fulcrumscholar.com',
      '*.fulcrumscholar.net',
      '*.fulcrumservices.org',
      '*.fulcrumservices.net'
    ],
  }
}
