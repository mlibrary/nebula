# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::haproxy {
  $cluster_name = lookup('nebula::profile::kubernetes::cluster')
  $cluster = lookup('nebula::profile::kubernetes::clusters')[$cluster_name]
  $node_cidr = pick($cluster['node_cidr'], lookup('nebula::profile::kubernetes::node_cidr'))

  $public_address = $cluster['public_address']
  $etcd_address = $cluster['etcd_address']
  $kube_api_address = $cluster['kube_api_address']
  $monitoring_user = lookup('nebula::profile::haproxy::monitoring_user')

  package { 'haproxy': }
  package { 'haproxyctl': }

  service { 'haproxy':
    ensure  => 'running',
    enable  => true,
    require => Package['haproxy'],
  }

  # If there is a keepalived service, restarting haproxy should also
  # restart keepalived. HAProxy notifies keepalived.
  Service['haproxy'] ~> Service <| title == 'keepalived' |>

  file { '/etc/haproxy/services.d':
    ensure => 'directory',
  }

  file { '/etc/default/haproxy':
    content => template('nebula/profile/kubernetes/haproxy/default.sh.erb'),
    notify  => Service['haproxy'],
  }

  ['api', 'etcd', 'gelf_tcp', 'http', 'https', 'https_alt', 'prometheus'].each |$service| {
    concat { "/etc/haproxy/services.d/${service}.cfg":
      notify => Service['haproxy'],
    }

    concat_fragment { "haproxy kubernetes ${service}":
      target  => "/etc/haproxy/services.d/${service}.cfg",
      order   => '01',
      content => template("nebula/profile/kubernetes/haproxy/services.d/${service}.cfg.erb"),
    }

    Concat_fragment <<| tag == "${cluster_name}_haproxy_kubernetes_${service}" |>>
  }

  firewall {
    default:
      proto  => 'tcp',
      state  => 'NEW',
      action => 'accept',
    ;

    '200 private api':
      dport  => 6443,
      source => $node_cidr,
    ;

    '200 private etcd':
      dport  => 2379,
      source => $node_cidr,
    ;

    '200 public http':
      dport => 80,
    ;

    '200 public https':
      dport => 443,
    ;

    '200 client cert prometheus https':
      dport => 9090,
    ;
  }

  nebula::exposed_port { '200 private https_alt':
    block => 'umich::networks::datacenter',
    port  => 8443,
  }

  nebula::exposed_port { '200 private gelf_tcp':
    block => 'umich::networks::datacenter',
    port  => 12201,
  }

  file { '/etc/haproxy/haproxy.cfg':
    notify  => Service['haproxy'],
    content => template('nebula/profile/kubernetes/haproxy/haproxy.cfg.erb'),
  }

  nebula::authzd_user { $monitoring_user['name']:
    gid  => 'haproxy',
    home => $monitoring_user['home'],
    key  => $monitoring_user['key'],
  }
}
