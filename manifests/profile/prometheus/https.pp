# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus::https {
  if $facts['mlibrary_ip_addresses']['public'] == undef or $facts['mlibrary_ip_addresses']['public'] == [] {
    class { 'nginx':
      server_tokens => 'off',
    }

    nginx::resource::server { 'prometheus':
      server_name       => [$::networking['fqdn']],
      listen_options    => 'proxy_protocol default_server',
      listen_port       => 443,
      proxy             => 'http://localhost:9090',
      ssl               => true,
      ssl_cert          => '/etc/prometheus/tls/tls.crt',
      ssl_key           => '/etc/prometheus/tls/tls.key',
      server_cfg_append => {
        'ssl_client_certificate' => '/etc/prometheus/tls/ca.crt',
        'ssl_verify_client'      => 'on',
        'ssl_verify_depth'       => 1,
      },
    }

    firewall { '200 HTTPS: Client Cert':
      proto => 'tcp',
      dport => [443],
      state => 'NEW',
      jump  => 'accept',
    }
  } else {
    class { 'nebula::profile::https_to_port':
      port => 9090,
    }

    nebula::exposed_port { '010 Prometheus HTTPS':
      port  => 443,
      block => 'umich::networks::all_trusted_machines',
    }
  }
}
