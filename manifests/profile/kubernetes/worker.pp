# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes Worker profile
#
# This opens up the ports we need open on workers. This does not start
# kubernetes or attempt to connect this node to the cluster. All it does
# is ensure the possibility of you doing it by hand.
class nebula::profile::kubernetes::worker {
  include nebula::profile::kubernetes

  $cluster = lookup('nebula::profile::kubernetes::cluster')

  @@concat_fragment { "haproxy nodeports ${::hostname}":
    target  => '/etc/haproxy/haproxy.cfg',
    order   => '04',
    content => "  server ${::hostname} ${::ipaddress} check port 30000\n",
    tag     => "${cluster}_haproxy_nodeports",
  }

  @@concat_fragment { "haproxy ip ${::hostname}":
    target  => '/etc/kubernetes_addresses.yaml',
    content => "addresses: {work: {${::hostname}: '${::ipaddress}'}}",
    tag     => "${cluster}_proxy_ips",
  }

  # Worker nodes accept connections from controller nodes for kubelet.
  Firewall <<| tag == "${cluster}_kubelet" |>>

  # Worker nodes accept connections from all nodes in the cluster for
  # the NodePort service.
  Firewall <<| tag == "${cluster}_NodePort" |>>

  Firewall <<| tag == "${cluster}_haproxy_nodeports" |>>
}
