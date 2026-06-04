# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# haproxy
#
# @example
#   include nebula::profile::haproxy
class nebula::profile::haproxy (
  Hash $services,
  Hash $monitoring_user,
  Boolean $master = false,
  Optional[String] $cert_source = undef,
  Hash $extra_floating_ips = {},
  String $global_badrobots = '',
) {
  include nebula::profile::haproxy::prereqs
  include nebula::profile::networking::sysctl
  class { 'nebula::profile::prometheus::exporter::haproxy':
    master => $master
  }

  file {
    default:
      ensure  => 'file',
      mode    => '0644',
      require => Package['haproxy'],
      notify  => Service['haproxy'],
    ;
    '/etc/haproxy/haproxy.cfg':
      content => template('nebula/profile/haproxy/haproxy.cfg.erb');
    '/etc/default/haproxy':
      content => template('nebula/profile/haproxy/default.erb');
    '/etc/haproxy/errors/hsts400.http':
      source => 'puppet:///modules/nebula/haproxy/errors/hsts400.http';
    '/etc/haproxy/global_badrobots.txt':
      content => $global_badrobots;
  }

  file { '/etc/haproxy/cloudflare-ipv4.txt':
    source => 'https://www.cloudflare.com/ips-v4',
  }

  file { '/etc/ssl/private' :
    ensure => 'directory',
    mode   => '0700',
    owner  => 'root',
    group  => 'root'
  }

  $services.filter |$service, $params| {
    'floating_ip' in $params
  }.each |$service, $params| {
    @nebula::haproxy::service { $service :
      cert_source => $cert_source,
      *           => $params
    }
  }

  Nebula::Haproxy::Binding <<| datacenter == $facts['datacenter'] |>>

  nebula::authzd_user { $monitoring_user['name']:
    gid     => 'haproxy',
    home    => $monitoring_user['home'],
    key     => $monitoring_user['key'],
    require => [Package['haproxy']]
  }

  ensure_packages(['jq','hactl'])
  $domain = lookup('umich::default_domain')
  file { '/usr/local/bin/reweight':
    ensure  => 'file',
    mode    => '0755',
    content => template('nebula/profile/haproxy/reweight.sh.erb')
  }

  package { 'keepalived': }
  package { 'ipset': }

  service { 'keepalived':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['keepalived'],
  }

  concat { '/etc/keepalived/keepalived.conf':
    ensure  => 'present',
    require => Package['keepalived'],
    notify  => Service['keepalived'],
    mode    => '0644',
  }

  concat_fragment { 'keepalived preamble':
    target  => '/etc/keepalived/keepalived.conf',
    content => template('nebula/profile/haproxy/keepalived/keepalived_pre.erb'),
    order   => '01'
  }

  @@concat_fragment { "keepalived node ip ${::networking['hostname']}":
    target  => '/etc/keepalived/keepalived.conf',
    content => "    ${::networking['ip']}\n",
    tag     => "keepalived-haproxy-ip-${facts['datacenter']}",
    order   => '02'
  }

  # don't collect our own IP address, just the other haproxy nodes here
  Concat_fragment <<| tag == "keepalived-haproxy-ip-${facts['datacenter']}" and title != "keepalived node ip ${::networking['hostname']}" |>>

  concat_fragment { 'keepalived postamble':
    target  => '/etc/keepalived/keepalived.conf',
    content => template('nebula/profile/haproxy/keepalived/keepalived_post.erb'),
    order   => '03'
  }

  file { '/etc/sysctl.d/keepalived.conf':
    ensure  => 'file',
    require => Package['keepalived'],
    notify  => [Service['keepalived'], Service['procps'], Service['haproxy']],
    mode    => '0644',
    content => template('nebula/profile/haproxy/keepalived/sysctl.conf.erb'),
  }

  @@firewall { "200 HTTP: HAProxy ${::networking['hostname']}":
    proto  => 'tcp',
    dport  => [80, 443],
    source => $::networking['ip'],
    state  => 'NEW',
    jump   => 'accept',
    tag    => "${facts['datacenter']}_haproxy"
  }

  # HAProxy should listen for kubernetes connections.
  nebula::exposed_port { '200 kubectl':
    port  => 6443,
    block => 'umich::networks::all_trusted_machines',
  }

  file { '/etc/haproxy/services.d/stats.cfg':
    require => 'Package[haproxy]',
    notify  => 'Service[haproxy]',
    content => template('nebula/profile/haproxy/stats_frontend.cfg.erb'),
  }

  logrotate::rule { 'haproxy':
    path         => '/var/log/haproxy.log',
    rotate_every => 'day',
    rotate       => 5,
    missingok    => true,
    ifempty      => false,
    compress     => true,
    postrotate   => ['/usr/lib/rsyslog/rsyslog-rotate', '/bin/systemctl restart filebeat'],
  }

  @nebula::taghosts::tag { 'haproxy': }
}
