# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Puppet Master with PuppetDB config
#
# @example
#   include nebula::profile::puppet::master_with_db
class nebula::profile::puppet::master_with_db (
  String $puppetdb_server = lookup('nebula::puppetdb'),
) {
  class { 'puppetdb::master::config':
    puppetdb_server => $puppetdb_server,
  }
}
