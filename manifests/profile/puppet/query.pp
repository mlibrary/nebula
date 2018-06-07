# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Tools for querying puppetdb
#
# @example
#   include nebula::profile::puppet::query
class nebula::profile::puppet::query (
  $ssl_group = '',
) {
  $puppetdb_server = lookup('nebula::puppetdb')

  package { 'curl': }

  file { '/usr/local/sbin/puppet-query':
    mode    => '0755',
    content => template('nebula/profile/puppet/query.sh.erb'),
  }

  file { '/etc/puppetlabs/puppet/ssl/private_keys':
    ensure  => 'directory',
    recurse => 'remote',
  }

  if ($ssl_group != '') {
    File['/etc/puppetlabs/puppet/ssl/private_keys'] {
      group  => $ssl_group,
    }
  }
}
