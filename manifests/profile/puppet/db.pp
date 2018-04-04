# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# PuppetDB
#
# @example
#   include nebula::profile::puppet::db
class nebula::profile::puppet::db {
  class { 'puppetdb':
    disable_cleartext => true,
    manage_firewall   => false,
    ssl_listen_port   => 443,
  }
}
