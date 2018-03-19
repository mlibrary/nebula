# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::dns::standard
#
# Set up standard resolv_conf.
#
# @example
#   include nebula::profile::dns::standard
class nebula::profile::dns::standard {
  class { 'resolv_conf':
    nameservers => lookup('nebula::resolv_conf::nameservers'),
    searchpath  => lookup('nebula::resolv_conf::searchpath'),
  }
}
