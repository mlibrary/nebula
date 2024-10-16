# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Mgetit log preparer
#
# @example
#   include nebula::role::mgetit_log
class nebula::role::mgetit_log {
  include nebula::role::umich
  include nebula::profile::nodejs
  include nebula::profile::php73
  include nebula::profile::ruby
}
