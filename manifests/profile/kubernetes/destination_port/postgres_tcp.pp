# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::destination_port::postgres_tcp {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy kubernetes postgres tcp ${::networking['hostname']}":
    target  => '/etc/haproxy/services.d/postgres_tcp.cfg',
    order   => '02',
    content => "  server ${::networking['hostname']} ${::networking['ip']}:30432 check\n",
    tag     => "${cluster_name}_haproxy_kubernetes_postgres_tcp",
  }
}
