# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal HathiTrust server
#
# @example
#   include nebula::role::hathitrust
class nebula::role::hathitrust {
  include nebula::profile::base
  include nebula::profile::dns::smartconnect
  include nebula::profile::beats
}
