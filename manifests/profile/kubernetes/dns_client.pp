# Copyright (c) 2020, 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::dns_client {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $private_domain = $cluster['private_domain']
  $router_address = $cluster['router_address']

  @@concat_fragment { "/etc/hosts ipv4 ${::ipaddress}":
    tag     => "${cluster_name}_etc_hosts_ip4_hostname",
    target  => '/etc/hosts',
    order   => '04',
    content => template('nebula/profile/kubernetes/dns/hosts_04_ipv4_hostname.erb'),
  }

  file { '/etc/resolv.conf':
    content => template('nebula/profile/kubernetes/dns/resolv.conf.erb'),
  }

  $::ssh.each |$name, $key_obj| {
    $type = $key_obj["type"]
    $key = $key_obj["key"]

    @@concat_fragment { "known ${cluster_name} host ${::hostname} ${name}":
      tag     => "${cluster_name}_known_host_public_keys",
      target  => '/etc/ssh/ssh_known_hosts',
      content => "${::hostname} ${type} ${key}\n",
    }
  }
}
