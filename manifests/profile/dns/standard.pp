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
  include nebula::resolv_conf
}
