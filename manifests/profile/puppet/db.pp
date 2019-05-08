# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# PuppetDB
#
# @example
#   include nebula::profile::puppet::db
class nebula::profile::puppet::db (
  $command_threads = undef,
  $concurrent_writes = undef,
) {
  class { 'puppetdb':
    disable_cleartext => true,
    manage_firewall   => false,
    command_threads   => $command_threads,
    concurrent_writes => $concurrent_writes,
  }
}
