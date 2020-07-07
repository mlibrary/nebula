# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::destination_port::http {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy kubernetes http ${::hostname}":
    target  => '/etc/haproxy/services.d/http.cfg',
    order   => '02',
    content => "  server ${::hostname} ${::ipaddress}:30080 check\n",
    tag     => "${cluster_name}_haproxy_kubernetes_http",
  }
}
