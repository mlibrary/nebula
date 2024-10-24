# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::destination_port::prometheus {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy kubernetes prometheus ${::hostname}":
    target  => '/etc/haproxy/services.d/prometheus.cfg',
    order   => '02',
    content => "  server ${::hostname} ${::ipaddress}:443 check send-proxy\n",
    tag     => "${cluster_name}_haproxy_kubernetes_prometheus",
  }
}
