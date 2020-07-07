# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::destination_port::etcd {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy kubernetes etcd ${::hostname}":
    target  => '/etc/haproxy/services.d/etcd.cfg',
    order   => '02',
    content => "  server ${::hostname} ${::ipaddress}:2379 check\n",
    tag     => "${cluster_name}_haproxy_kubernetes_etcd",
  }
}
