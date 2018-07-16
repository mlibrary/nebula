# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# haproxy
#
# @example
#   include nebula::profile::haproxy
class nebula::profile::haproxy(
  Hash $services,
  Hash $monitoring_user,
  String $cert_source = '',
) {
  require nebula::profile::haproxy::prereqs

  $balanced_frontends = balanced_frontends()

  file { '/etc/haproxy/haproxy.cfg':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/haproxy.cfg.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  file { '/etc/default/haproxy':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/default.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  file { '/etc/ssl/private' :
    ensure => 'directory',
    mode   => '0700',
    owner  => 'root',
    group  => 'root'
  }

  $balanced_frontends.each |$service, $node_names| {
    nebula::haproxy_service { $service :
      cert_source => $cert_source,
      node_names  => $node_names,
      *           => $services[$service]
    }
  }

  nebula::authzd_user { $monitoring_user['name']:
    gid  => 'haproxy',
    home => $monitoring_user['home'],
    key  => $monitoring_user['key']
  }

}
