# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# haproxy
#
# @example
#   include nebula::profile::haproxy
class nebula::profile::haproxy(Hash $floating_ips, String $cert_source, Hash $monitoring_user) {
  service { 'haproxy':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  package { 'haproxy': }
  package { 'haproxyctl': }

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
    $floating_ip = $floating_ips[$service]

    file { "/etc/haproxy/${service}.cfg":
      ensure  => 'present',
      mode    => '0644',
      content => template('nebula/profile/haproxy/service.cfg.erb'),
      require => Package['haproxy'],
      notify  => Service['haproxy'],
    }

    if $cert_source != '' {
      file { "/etc/ssl/private/${service}":
        ensure  => 'directory',
        mode    => '0700',
        owner   => 'haproxy',
        group   => 'haproxy',
        recurse => true,
        purge   => true,
        links   => 'follow',
        notify  => Service['haproxy'],
        source  => "puppet://${cert_source}/${service}"
      }
    }
  }

  nebula::authzd_user { $monitoring_user['name']:
    gid  => 'haproxy',
    home => $monitoring_user['home'],
    key  => $monitoring_user['key']
  }

}
