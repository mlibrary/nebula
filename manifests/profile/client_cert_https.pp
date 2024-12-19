# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::client_cert_https
#
# If there is an http service listening on 127.0.0.1 on some port, this
# profile can add client certs and verify that any would-be visitors are
# also using valid client certs, all protected by https.
#
# @param http_port The port that the http service is already listening on
# @param https_port The port that clients will connect to with https
# @param server_name The dns address that clients will connect to
# @param allow_cidr Client requests will be permitted from this cidr
# @param certs_source_prefix Directory to find certificate files
# @param ca_source Full path to CA file; defaults to ca.crt
# @param cert_source Full path to client certificate; defaults to $fqdn.crt
# @param key_source Full path to client key; defaults to $fqdn.key
# @param http_service_name An informative name of the http service
class nebula::profile::client_cert_https (
  Integer $http_port = 80,
  Integer $https_port = 443,
  String $server_name = $::networking['fqdn'],
  String $allow_cidr = '0.0.0.0/0',
  String $certs_source_prefix = 'puppet:///pki',
  Optional[String] $ca_source = undef,
  Optional[String] $cert_source = undef,
  Optional[String] $key_source = undef,
  String $http_service_name = 'unspecified http service',
) {
  $full_ca_source = case $ca_source {
    String: { $ca_source }
    default: { "${certs_source_prefix}/ca.crt" }
  }

  $full_cert_source = case $cert_source {
    String: { $cert_source }
    default: { "${certs_source_prefix}/${::networking['fqdn']}.crt" }
  }

  $full_key_source = case $key_source {
    String: { $key_source }
    default: { "${certs_source_prefix}/${::networking['fqdn']}.key" }
  }

  class { 'nginx':
    server_tokens => 'off',
  }

  nginx::resource::server { 'client_cert_https':
    server_name       => [$server_name],
    listen_options    => 'default_server',
    listen_port       => $https_port,
    proxy             => "http://localhost:${http_port}",
    ssl               => true,
    ssl_cert          => '/etc/nginx/tls/tls.crt',
    ssl_key           => '/etc/nginx/tls/tls.key',
    server_cfg_append => {
      'ssl_client_certificate' => '/etc/nginx/tls/ca.crt',
      'ssl_verify_client'      => 'on',
      'ssl_verify_depth'       => 1,
    }
  }

  firewall { "200 HTTPS: client-cert protected ${http_service_name}":
    proto  => 'tcp',
    dport  => [$https_port],
    source => $allow_cidr,
    state  => 'NEW',
    jump   => 'accept',
  }

  file { '/etc/nginx/tls':
    ensure  => 'directory',
    mode    => '0755',
    require => File['/etc/nginx'],
  }

  file { '/etc/nginx/tls/ca.crt':
    mode    => '0644',
    source  => $full_ca_source,
    require => File['/etc/nginx/tls'],
    notify  => Nginx::Resource::Server['client_cert_https'],
  }

  file { '/etc/nginx/tls/tls.crt':
    mode    => '0644',
    source  => $full_cert_source,
    require => File['/etc/nginx/tls'],
    notify  => Nginx::Resource::Server['client_cert_https'],
  }

  file { '/etc/nginx/tls/tls.key':
    mode    => '0400',
    source  => $full_key_source,
    require => File['/etc/nginx/tls'],
    notify  => Nginx::Resource::Server['client_cert_https'],
  }
}
