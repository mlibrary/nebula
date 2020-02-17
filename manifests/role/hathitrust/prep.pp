# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust prep
#
# @example
#   include nebula::role::hathitrust::prep
class nebula::role::hathitrust::prep (
  String $internal_routing = '',
) {
  class { 'nebula::role::hathitrust':
    internal_routing => $internal_routing,
  }
}
