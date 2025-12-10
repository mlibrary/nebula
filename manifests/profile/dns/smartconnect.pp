# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::dns::smartconnect
#
# Deprecated. Accepts all parameters that it previously did, but ignores them.
# This profile only exists to:
#    - ensure catalogs that use it compile until they are rewritten
#    - delete `nameserver 127.0.0.1` from resolv.conf
#
class nebula::profile::dns::smartconnect (
  String $domain,
  String $nameserver,
  Array  $master_zones,
  Array  $other_ns_ips = [],
) {
  include stdlib

  class { 'nebula::resolv_conf': }
}
