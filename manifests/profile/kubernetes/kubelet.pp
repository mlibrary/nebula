# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::kubelet {
  include nebula::profile::kubernetes::apt
  include nebula::systemd::daemon_reload

  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]

  $kubernetes_version = $cluster['kubernetes_version']
  $public_address = $cluster['public_address']
  $router_address = $cluster['router_address']
  $etcd_address = $cluster['etcd_address']
  $kube_api_address = $cluster['kube_api_address']
  $node_cidr = pick($cluster['node_cidr'], lookup('nebula::profile::kubernetes::node_cidr'))

  if $kubernetes_version == undef {
    fail('You must set a specific kubernetes version')
  }

  if $public_address == undef {
    fail('You must set a public IP address for the cluster')
  }

  if $router_address == undef {
    fail("You must set a router IP address for the cluster's gateway")
  }

  if $etcd_address == undef {
    fail("You must set an etcd IP address for the cluster's gateway")
  }

  if $kube_api_address == undef {
    fail("You must set a kube api IP address for the cluster's gateway")
  }

  $os_name = $facts['os']['name']
  $os_major = $facts['os']['release']['major']
  $os = "${os_name}_${os_major}"
  $version = $kubernetes_version.regsubst(/\.[^.]+$/, '')
  apt::source { 'cri-o-stable':
    location => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/",
    release  => '/',
    repos    => '',
    key      => {
      'id'     => '2472D6D0D2F66AF87ABA8DA34D64390375060AA4',
      'source' => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/Release.key"
    }
  }
  apt::source { 'cri-o-specific':
    location => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${version}/${os}/",
    release  => '/',
    repos    => '',
    key      => {
      'id'     => '2472D6D0D2F66AF87ABA8DA34D64390375060AA4',
      'source' => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${version}/${os}/Release.key"
    }
  }
  package { 'cri-o':
    require => Package['cri-o-runc'],
    notify  => Exec['/bin/systemctl daemon-reload']
  }
  package { 'cri-o-runc':
    require => Apt::Source['cri-o-stable', 'cri-o-specific']
  }
  service { 'crio':
    require => Package['cri-o']
  }
  kmod::load { 'br_netfilter': }
  file { '/etc/default/grub.d/cgroup.cfg':
    content => "GRUB_CMDLINE_LINUX=systemd.unified_cgroup_hierarchy=false\n",
    notify  => Exec['/usr/sbin/update-grub']
  }
  exec { '/usr/sbin/update-grub':
    refreshonly => true,
  }

  service { 'kubelet':
    ensure  => 'running',
    enable  => true,
    require => Package['kubelet'],
  }

  package { 'kubelet':
    ensure  => "${kubernetes_version}-00",
    require => Apt::Source['kubernetes'],
  }

  apt::pin { 'kubelet':
    packages => ['kubelet'],
    version  => "${kubernetes_version}-00",
    priority => 999,
  }

  firewall {
    default:
      proto  => 'tcp',
      source => $node_cidr,
      state  => 'NEW',
      action => 'accept',
    ;

    '200 Cluster ssh':
      dport => 22,
    ;

    '200 Cluster BGP':
      dport => 179,
    ;

    '200 Cluster VXLAN':
      dport => 4789,
      proto => 'udp',
    ;

    '200 Cluster etcd':
      dport => ['2379', '2380'],
    ;

    '200 Cluster kubelet':
      dport => 10250,
    ;

    '200 Cluster kubernetes API':
      dport => 6443,
    ;

    '200 Cluster NodePorts':
      dport => '30000-32767',
    ;

    '200 Cluster Prometheus':
      dport => 9100,
    ;

    '200 Cluster Calico Typha':
      dport => 5473,
    ;
  }
}
