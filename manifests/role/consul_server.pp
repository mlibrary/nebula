# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::consul_server {
  include nebula::role::minimum
  include nebula::profile::consul::server
}
