# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting www.lib.umich.edu
#
# @example
#   include nebula::role::webhost::www_lib
class nebula::role::webhost::www_lib {
  include nebula::role::umich
  include nebula::profile::elastic::filebeat::prospectors::clickstream

  @@nebula::haproxy::binding { "${::hostname} www-lib":
      service       => 'www-lib',
      https_offload => true,
      datacenter    => $::datacenter,
      hostname      => $::hostname,
      ipaddress     => $::ipaddress
  }

}
