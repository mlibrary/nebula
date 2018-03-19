# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::puppet::mgmt
#
# Install everything a puppet server needs
#
# @example
#   include nebula::profile::puppet::mgmt
class nebula::profile::puppet::mgmt {
  include puppetdb
  include puppetdb::master::config
  require nebula::profile::ruby
  $global_version = lookup('nebula::profile::ruby::global_version')

  ['r10k', 'librarian-puppet'].each |$gem| {
    rbenv::gem { $gem:
      ruby_version => $global_version,
      require      => Rbenv::Build[$global_version],
    }
  }

  tidy { '/opt/puppetlabs/server/data/puppetserver/reports':
    age     => '1w',
    recurse => true,
  }
}
