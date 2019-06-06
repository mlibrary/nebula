# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# A server with this role will have docker and pretty much nothing else.
class nebula::role::minimal_docker ()
{
  include nebula::role::minimum
  include nebula::profile::docker
}
