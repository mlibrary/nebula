# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::authz_test {
  include nebula::role::minimum
  include nebula::profile::authz_test
}
