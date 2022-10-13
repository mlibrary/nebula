# Copyright (c) 2019-2020, 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::keepalived (
  Boolean $master = false,
) {
  include nebula::profile::networking::sysctl

  $email = lookup('nebula::root_email')

  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $control_dns = $cluster['control_dns']
  $public_address = $cluster['public_address']
  $private_address = $cluster['private_address']
  $router_address = $cluster['router_address']
  $etcd_address = $cluster['etcd_address']
  $kube_api_address = $cluster['kube_api_address']

  concat_fragment { 'keepalived preamble':
    target  => '/etc/keepalived/keepalived.conf',
    order   => '01',
    content => template('nebula/profile/kubernetes/keepalived/keepalived_01.erb'),
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
    content => template('nebula/profile/kubernetes/keepalived/keepalived_99.erb'),
  }

  concat { '/etc/keepalived/keepalived.conf':
    notify => Service['keepalived'],
  }

  file { '/etc/sysctl.d/keepalived.conf':
    content => template('nebula/profile/kubernetes/keepalived/sysctl.conf.erb'),
    notify  => Service['keepalived', 'procps'],
  }

  service { 'keepalived':
    ensure  => 'running',
    enable  => true,
    require => Package['keepalived', 'ipset'],
  }

  package { 'keepalived': }
  package { 'ipset': }

  $::ssh.each |$name, $key_obj| {
    $type = $key_obj["type"]
    $key = $key_obj["key"]

    @@concat_fragment { "known host ${control_dns} ${::fqdn} ${name}":
      tag     => 'known_host_public_keys',
      target  => '/etc/ssh/ssh_known_hosts',
      content => "${control_dns} ${type} ${key}\n",
    }
  }
}
