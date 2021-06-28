# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::destination_port::https_alt {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy kubernetes https alt ${::hostname}":
    target  => '/etc/haproxy/services.d/https_alt.cfg',
    order   => '02',
    content => "  server ${::hostname} ${::ipaddress}:31443 check\n",
    tag     => "${cluster_name}_haproxy_kubernetes_https_alt",
  }
}
