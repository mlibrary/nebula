# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::consul::agent (
  $gossip_encryption_key = '',
  $pems = {},
  $ca = '',
  $hostname = $::hostname,
) {
  package { 'consul':
    require => Apt::Source['hashicorp'],
  }

  file { '/etc/consul.d':
    ensure => 'directory',
    owner  => 'consul',
    group  => 'consul',
  }

  file { '/etc/consul.d/consul-agent-ca.pem':
    content => $ca,
    owner   => 'consul',
    group   => 'consul',
    mode    => '0644',
  }

  $pems.each |$filename, $content| {
    file { "/etc/consul.d/${filename}":
      content => $content,
      owner   => 'consul',
      group   => 'consul',
      mode    => $filename ? {
        /^.*-key\.pem$/ => '0640',
        default         => '0644',
      },
    }
  }

  file { '/etc/consul.d/consul.hcl':
    content => template('nebula/profile/consul/agent.hcl.erb'),
    owner   => 'consul',
    group   => 'consul',
    mode    => '0640',
  }

  apt::source { 'hashicorp':
    location => 'https://apt.releases.hashicorp.com',
    release  => $facts['os']['distro']['codename'],
    key      => {
      'id'     => 'E8A032E094D8EB4EA189D270DA418C88A3219F7B',
      'source' => 'https://apt.releases.hashicorp.com/gpg',
    },
  }

  nebula::exposed_port {
    default:
      block => 'umich::networks::private_lan',
    ;

    '020 Consul LAN Serf (tcp)':
      port => 8301,
    ;

    '020 Consul LAN Serf (udp)':
      port     => 8301,
      protocol => 'udp',
    ;

    '020 Consul Sidecar Proxy':
      port => '21000-21255',
    ;

    '020 Consul Expose Check':
      port => '21500-21755',
    ;
  }
}
