# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Puppet Master config
#
# @example
#   include nebula::profile::puppet::master
class nebula::profile::puppet::master (
  String $puppetdb_server = lookup('nebula::puppetdb'),
) {
  class { 'puppetdb::master::config':
    puppetdb_server => $puppetdb_server,
  }

  include nebula::profile::ruby
  $global_version = lookup('nebula::profile::ruby::global_version')

  ['r10k', 'librarian-puppet'].each |$gem| {
    rbenv::gem { $gem:
      ruby_version => $global_version,
      require      => [
        Class['nebula::profile::ruby'],
        Rbenv::Build[$global_version],
      ],
    }
  }

  tidy { '/opt/puppetlabs/server/data/puppetserver/reports':
    age     => '1w',
    recurse => true,
  }
}
