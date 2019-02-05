# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting www.lib.umich.edu and deepblue.lib.umich.edu
#
# @example
#   include nebula::role::webhost::www_lib_deepblue
class nebula::role::webhost::www_lib_deepblue {
  include nebula::role::webhost::www_lib

  @@nebula::haproxy::binding { "${::hostname} deepblue":
      service       => 'deepblue',
      https_offload => true,
      datacenter    => $::datacenter,
      hostname      => $::hostname,
      ipaddress     => $::ipaddress;
  }

}
