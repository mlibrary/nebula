# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::destination_port::http_alt {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy kubernetes http alt ${::hostname}":
    target  => '/etc/haproxy/services.d/http_alt.cfg',
    order   => '02',
    content => "  server ${::hostname} ${::ipaddress}:31080 check\n",
    tag     => "${cluster_name}_haproxy_kubernetes_http_alt",
  }
}
