# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes general profile
#
# This installs all the necessary software for kubernetes to run on this
# node, whether it's a controller node, an etcd node, or a worker node.
# It also announces its intention to listen on all the ports that are
# supposed to be open to the entire cluster.
#
# Both parameters are required, and the cluster must be a key in the
# clusters hash. Furthermore, you must set, at minimum, a kubernetes
# version, a docker version, and a control dns for each cluster; there
# are no default values.
#
# Our model for kubernetes has three roles: gateway, controller, and
# worker. The gateways exist outside the actual cluster but provide the
# entrypoint. The controllers manage the distribution of pods and
# services in the cluster, and the workers run what they're told to run.
#
# Most of puppet's role in this is to ensure they're all listening to
# each other. Here's a table of who listens to whom (I use "all
# internal" to refer to both controller and worker nodes but not gateway
# nodes):
#
# Listening node Port(s)     Nodes to listen for   Purpose
# -------------- ----------- --------------------- ---------------------
# Gateway        6443        All trusted computers kubectl
# Gateway        30000-32767 All trusted computers NodePorts
# Gateway        80? 443?    The world?            (If we want web apps)
# All internal   179, 4789   All internal          Internal networking
# All internal   10250       Controllers           kubelet
# All internal   10250       All internal          prometheus
# Controller     6443        Gateways              kubectl
# Controller     6443        All internal          Management API
# Controller     2379, 2380  Controllers           etcd
# Worker         30000-32767 Gateways              NodePorts access
# Worker         30000-32767 All internal          NodePorts
#
# @param cluster The unique name of the cluster.
# @param clusters A hash of cluster names to cluster definitions.
class nebula::profile::kubernetes (
  String             $cluster,
  Hash[String, Hash] $clusters,
) {
  $kubernetes_version = $clusters[$cluster]['kubernetes_version']
  $docker_version = $clusters[$cluster]['docker_version']
  $control_dns = $clusters[$cluster]['control_dns']

  if $kubernetes_version == undef {
    fail('You must set a specific kubernetes version')
  }

  if $docker_version == undef {
    fail('You must set a specific docker version')
  }

  if $control_dns == undef {
    fail('You must set a specific load-balanced control dns')
  }

  package { ['kubeadm', 'kubelet']:
    ensure  => "${kubernetes_version}-00",
    require => [Apt::Source['kubernetes'], Class['docker']],
  }

  apt::pin { 'kubernetes':
    packages => ['kubeadm', 'kubelet'],
    version  => "${kubernetes_version}-00",
    priority => 999,
  }

  apt::source { 'kubernetes':
    location => 'https://apt.kubernetes.io/',
    release  => 'kubernetes-xenial',
    repos    => 'main',
    key      => {
      'id'     => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
      'source' => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
    },
  }

  class { 'nebula::profile::docker':
    version                => $docker_version,
    docker_compose_version => '',
  }

  @@firewall {
    default:
      proto  => 'tcp',
      source => $::ipaddress,
      state  => 'NEW',
      action => 'accept',
    ;

    # All nodes in this cluster will need to access the controllers over
    # 6443 for the main API.
    "200 ${cluster} API ${::fqdn}":
      tag   => "${cluster}_API",
      dport => 6443,
    ;

    # All nodes in this cluster will need to access the workers over
    # 30000-32767 for the NodePort service.
    "200 ${cluster} NodePort ${::fqdn}":
      tag   => "${cluster}_NodePort",
      dport => '30000-32767',
    ;

    # All nodes in this cluster will need to access all nodes in this
    # cluster over 10250 for kubelet.
    "200 ${cluster} kubelet ${::fqdn}":
      tag   => "${cluster}_kubelet",
      dport => 10250,
    ;

    "200 ${cluster} BGP ${::fqdn}":
      tag   => "${cluster}_BGP",
      dport => 179,
    ;

    "200 ${cluster} VXLAN ${::fqdn}":
      tag   => "${cluster}_VXLAN",
      dport => 4789,
      proto => 'udp',
    ;
  }

  Firewall <<| tag == "${cluster}_BGP" |>>
  Firewall <<| tag == "${cluster}_VXLAN" |>>
}
