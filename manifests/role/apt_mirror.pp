# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::apt_mirror
#
# Debian apt mirror
#
# @example
#   include nebula::role::apt_mirror
class nebula::role::apt_mirror {
  include nebula::role::aws
  include nebula::profile::apt_mirror
}
