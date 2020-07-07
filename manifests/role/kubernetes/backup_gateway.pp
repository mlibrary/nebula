# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::kubernetes::backup_gateway {
  include nebula::role::minimum
  include nebula::profile::kubernetes::dns_server
  include nebula::profile::kubernetes::kubectl
  include nebula::profile::kubernetes::haproxy
  include nebula::profile::kubernetes::router
  include nebula::profile::kubernetes::bootstrap::source
  include nebula::profile::kubernetes::keepalived
}
