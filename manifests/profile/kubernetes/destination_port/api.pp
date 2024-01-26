# Copyright (c) 2020, 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::destination_port::api {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy kubernetes api ${::hostname}":
    target  => '/etc/haproxy/services.d/api.cfg',
    order   => '02',
    content => "  server ${::hostname} ${::ipaddress}:6443 check ssl verify none\n",
    tag     => "${cluster_name}_haproxy_kubernetes_api",
  }
}
