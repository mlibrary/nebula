# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::etcdctl {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $etcdctl_endpoints = $cluster["etcdctl_endpoints"]

  package { "etcd-client": }

  file { "/etc/etcd":
    ensure => "directory",
  }

  file { "/etc/profile.d/etcdctl.sh":
    content => template("nebula/profile/kubernetes/etcdctl.sh.erb"),
  }

  file { "/etc/etcd/README":
    content => @("README")
      You just kind of have to do this yourself whenever etcd certs get renewed:

      scp etcd-10:/etc/kubernetes/pki/ca.crt /etc/etcd
      scp etcd-10:/etc/kubernetes/pki/peer.crt /etc/etcd
      scp etcd-10:/etc/kubernetes/pki/peer.key /etc/etcd
      | README
  }
}
