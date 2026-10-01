# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::client_certs {
  include nebula::profile::prometheus::prereqs

  file { '/etc/prometheus/tls':
    ensure  => 'directory',
    require => Package['prometheus'],
  }

  file { '/etc/prometheus/tls/ca.crt':
    source => 'puppet:///ssl-certs/prometheus-pki/ca.crt',
    mode   => '0644',
    owner  => 'prometheus',
    group  => 'prometheus',
    notify => Service['prometheus'],
  }

  file { '/etc/prometheus/tls/tls.crt':
    source => "puppet:///ssl-certs/prometheus-pki/${facts['networking']['fqdn']}.crt",
    mode   => '0644',
    owner  => 'prometheus',
    group  => 'prometheus',
    notify => Service['prometheus'],
  }

  file { '/etc/prometheus/tls/tls.key':
    source => "puppet:///ssl-certs/prometheus-pki/${facts['networking']['fqdn']}.key",
    mode   => '0600',
    owner  => 'prometheus',
    group  => 'prometheus',
    notify => Service['prometheus'],
  }
}
