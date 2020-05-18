# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Kubernetes HAProxy profile
#
# This is for the gateway to a kubernetes cluster. In kubernetes terms,
# this exists outside the actual cluster, but, since we need to be able
# to access the cluster, this role is essential.
#
# @param master Exactly one gateway per cluster should be designated as
#   the master so that any others will simply exist as failover nodes.
# @param cluster The name of the cluster to serve as ambassador to. This
#   defaults to nebula::profile::kubernetes::cluster, and you should
#   almost certainly set that instead.
class nebula::profile::legacy::kubernetes::haproxy (
  Boolean $master = false,
  String $cluster = '',
) {
  include nebula::profile::networking::sysctl

  if $cluster == '' {
    $cluster_name = lookup('nebula::profile::legacy::kubernetes::cluster')
  } else {
    $cluster_name = $cluster
  }

  $email = lookup('nebula::root_email')
  $floating_ip = lookup('nebula::profile::legacy::kubernetes::clusters')[$cluster_name]['address']
  $monitoring_user = lookup('nebula::profile::haproxy::monitoring_user')

  concat_fragment { 'haproxy defaults':
    target  => '/etc/haproxy/haproxy.cfg',
    order   => '01',
    content => template('nebula/profile/kubernetes/haproxy/haproxy.cfg.erb'),
  }

  Concat_fragment <<| tag == "${cluster_name}_haproxy_kubectl" |>>

  concat_fragment { 'haproxy nodeports':
    target  => '/etc/haproxy/haproxy.cfg',
    order   => '03',
    content => "\nlisten nodeports\n  bind ${floating_ip}:30000-32767\n  mode tcp\n  option tcp-check\n  balance roundrobin\n",
  }

  Concat_fragment <<| tag == "${cluster_name}_haproxy_nodeports" |>>

  concat { '/etc/haproxy/haproxy.cfg':
    notify => Service['haproxy', 'keepalived'],
  }

  file { '/etc/default/haproxy':
    content => "CONFIG=\"/etc/haproxy/haproxy.cfg\"\n",
    notify  => Service['haproxy', 'keepalived'],
  }

  nebula::authzd_user { $monitoring_user['name']:
    gid  => 'haproxy',
    home => $monitoring_user['home'],
    key  => $monitoring_user['key'],
  }

  concat_fragment { 'keepalived preamble':
    target  => '/etc/keepalived/keepalived.conf',
    order   => '01',
    content => template('nebula/profile/kubernetes/haproxy/keepalived_pre.erb'),
  }

  @@concat_fragment { "keepalived ${::hostname}":
    target  => '/etc/keepalived/keepalived.conf',
    order   => '02',
    content => "    ${::ipaddress}\n",
    tag     => "${cluster_name}_keepalived",
  }

  # Don't collect own IP address, but otherwise get everyone else in
  # this cluster.
  Concat_fragment <<| tag == "${cluster_name}_keepalived" and title != "keepalived ${::hostname}" |>>

  concat_fragment { 'keepalived postamble':
    target  => '/etc/keepalived/keepalived.conf',
    order   => '99',
    content => template('nebula/profile/kubernetes/haproxy/keepalived_post.erb'),
  }

  concat { '/etc/keepalived/keepalived.conf':
    notify => Service['keepalived'],
  }

  file { '/etc/sysctl.d/keepalived.conf':
    content => template('nebula/profile/haproxy/keepalived/sysctl.conf.erb'),
    notify  => Service['keepalived', 'procps', 'haproxy'],
  }

  concat_fragment { 'haproxy floating ip':
    target  => '/etc/kubernetes_addresses.yaml',
    content => "addresses: {floating: {${cluster_name}: '${floating_ip}'}}",
  }

  concat_fragment { 'haproxy unicast ip':
    target  => '/etc/kubernetes_addresses.yaml',
    content => "addresses: {unicast: {${::hostname}: '${::ipaddress}'}}",
  }

  @@concat_fragment { "haproxy ip ${::hostname}":
    target  => '/etc/kubernetes_addresses.yaml',
    content => "addresses: {peers: {${::hostname}: '${::ipaddress}'}}",
    tag     => "${cluster_name}_proxy_ips",
  }

  Concat_fragment <<| tag == "${cluster_name}_proxy_ips" and title != "haproxy ip ${::hostname}" |>>

  concat_file { '/etc/kubernetes_addresses.yaml':
    format => 'yaml',
  }

  service { 'keepalived':
    ensure  => 'running',
    enable  => true,
    require => Package['keepalived', 'ipset'],
    notify  => Service['haproxy'],
  }

  service { 'haproxy':
    ensure  => 'running',
    enable  => true,
    require => Package['haproxy'],
  }

  package { 'haproxy': }
  package { 'haproxyctl': }
  package { 'keepalived': }
  package { 'ipset': }

  nebula::exposed_port { '200 kubectl':
    port  => 6443,
    block => 'umich::networks::all_trusted_machines',
  }

  nebula::exposed_port { '300 NodePorts':
    port  => '30000-32767',
    block => 'umich::networks::all_trusted_machines',
  }

  @@firewall { "200 kubectl: ${::hostname}":
    proto  => 'tcp',
    dport  => 6443,
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
    tag    => "${cluster_name}_haproxy_kubectl",
  }

  @@firewall { "300 NodePorts: ${::hostname}":
    proto  => 'tcp',
    dport  => '30000-32767',
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
    tag    => "${cluster_name}_haproxy_nodeports",
  }
}
