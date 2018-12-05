# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Ingest and indexing servers for hathitrust.org
#
# @example
#   include nebula::role::hathitrust::ingest_indexing
class nebula::role::hathitrust::ingest_indexing (String $private_address_template = '192.168.0.%s') {
  include nebula::role::hathitrust_new_firewall

  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }

  include nebula::profile::hathitrust::dbhost
  include nebula::profile::hathitrust::mounts
  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl
}