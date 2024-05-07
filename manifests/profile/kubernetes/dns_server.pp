# Copyright (c) 2020, 2022-2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::dns_server {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $etcd_address = $cluster['etcd_address']
  $kube_api_address = $cluster['kube_api_address']
  $node_cidr = $cluster['node_cidr']
  $private_domain = $cluster['private_domain']
  $private_zones = $cluster['private_zones']

  package { 'dnsmasq': }

  service { 'dnsmasq':
    require => Package['dnsmasq'],
  }

  concat { '/etc/hosts':
    notify => Service['dnsmasq'],
  }

  Concat_fragment <<| tag == "${cluster_name}_etc_hosts_ip4_hostname" |>>

  concat_fragment {
    default:
      target => '/etc/hosts',
    ;

    '/etc/hosts ipv4 localhost':
      content => template('nebula/profile/kubernetes/dns/hosts_01_ipv4_localhost.erb'),
      order   => '01',
    ;

    '/etc/hosts ipv4 etcd-all':
      content => template('nebula/profile/kubernetes/dns/hosts_02_etcd_all.erb'),
      order   => '02',
    ;

    '/etc/hosts ipv4 kube-api':
      content => template('nebula/profile/kubernetes/dns/hosts_03_kube_api.erb'),
      order   => '03',
    ;

    '/etc/hosts ipv6 localhost':
      content => template('nebula/profile/kubernetes/dns/hosts_05_ipv6_localhost.erb'),
      order   => '05',
    ;

    '/etc/hosts ipv6 debian':
      content => template('nebula/profile/kubernetes/dns/hosts_06_ipv6_debian.erb'),
      order   => '06',
    ;
  }

  concat { '/etc/ssh/ssh_known_hosts': }
  Concat_fragment <<| tag == "${cluster_name}_known_host_public_keys" |>>

  file { "/etc/dnsmasq.d/local_domain":
    content => "local=/${private_domain}/\n",
    notify  => Service['dnsmasq']
  }

  if $private_zones {
    $private_zones.each |Hash $zone| {
      file { "/etc/dnsmasq.d/${$zone[name]}":
        content => "server=/${$zone[domain]}/${$zone[resolver]}\n",
        notify  => Service['dnsmasq']
      }
    }
  }

  firewall {
    default:
      dport  => 53,
      source => $node_cidr,
      state  => 'NEW',
      action => 'accept',
    ;

    '200 Nameserver (TCP)':
      proto => 'tcp',
    ;

    '200 Nameserver (UDP)':
      proto => 'udp',
    ;
  }
}
