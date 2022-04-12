# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::apache::fulcrum
#
# Apache config and surrounding setup required to be a fulcrum.org web server.
# Note that this is different than a web server fully able to run an instance
# of Fulcrum. This profile includes all of the official domains and redirects
# for Fulcrum-the-service.
class nebula::profile::www_lib::apache::fulcrum (
) {
  @nebula::apache::ssl_keypair { 'fulcrum.org': }

  include nebula::profile::www_lib::vhosts::fulcrum

  nebula::apache::redirect_vhost_https {
    default:
      ssl_cn        => 'fulcrum.org',
      priority      => '08',
    ;

    'northwestern.fulcrumscholar.org':
      target        => 'https://www.fulcrum.org/northwestern',
      serveraliases => ['northwestern.fulcrum.org', 'northwestern.fulcrumservices.org'],
    ;

    'minnesota.fulcrumscholar.org':
      target        => 'https://www.fulcrum.org/minnesota',
      serveraliases => [ 'minnesota.fulcrum.org', 'minnesota.fulcrumservices.org'],
    ;

    'michigan.fulcrumscholar.org':
      target        => 'https://www.fulcrum.org/michigan',
      serveraliases => [ 'michigan.fulcrum.org', 'michigan.fulcrumservices.org'],
    ;

    'indiana.fulcrumscholar.org':
      target        => 'https://www.fulcrum.org/indiana',
      serveraliases => [ 'indiana.fulcrum.org', 'indiana.fulcrumservices.org'],
    ;

    'pennstate.fulcrumscholar.org':
      target        => 'https://www.fulcrum.org/pennstate',
      serveraliases => [ 'pennstate.fulcrum.org', 'pennstate.fulcrumservices.org'],
    ;

    'nyupress.fulcrumscholar.org':
      target        => 'https://www.fulcrum.org/nyupress',
      serveraliases => [ 'nyupress.fulcrum.org', 'nyupress.fulcrumservices.org'],
    ;

    'dialogue.fulcrumscholar.org':
      target        => 'https://www.fulcrum.org/dialogue',
      serveraliases => [ 'dialogue.fulcrum.org', 'dialogue.fulcrumservices.org'],
    ;

    'fulcrum.www.lib.umich.edu':
      target        => 'https://www.fulcrum.org/',
      serveraliases => ['fulcrum.lib.umich.edu'],
    ;
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
