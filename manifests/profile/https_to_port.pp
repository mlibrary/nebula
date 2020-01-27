# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Forward HTTPS to a local port
#
# This allows us to expose what would be an HTTP port as HTTPS instead.
# It also creates a simple webroot to use with actual HTTP connections
# so that cert verification can be automatic.
#
# @param port The local HTTP port to forward HTTPS connections to
# @param server_name The domain we expect connections to (defaults to
#   the fqdn fact)
# @param webroot The path to where we want HTTP connections over port 80
#   to land (defaults to `/var/www`)
class nebula::profile::https_to_port (
  Integer $port,
  String $server_name = $::fqdn,
  String $webroot = '/var/www',
) {
  include nginx

  $letsencrypt_directory = $::letsencrypt_directory[$server_name]

  if $letsencrypt_directory {
    nginx::resource::server { 'https-forwarder':
      server_name => [$server_name],
      listen_port => 443,
      proxy       => "http://localhost:${port}",
      ssl         => true,
      ssl_cert    => "${letsencrypt_directory}/fullchain.pem",
      ssl_key     => "${letsencrypt_directory}/privkey.pem",
      require     => Nebula::Cert[$server_name],
    }
  }

  nebula::cert { $server_name:
    webroot => $webroot,
    require => Nginx::Resource::Server['letsencrypt-webroot'],
  }

  nginx::resource::server { 'letsencrypt-webroot':
    server_name => [$server_name],
    listen_port => 80,
    www_root    => $webroot,
    require     => File[$webroot],
  }

  file { $webroot:
    ensure => 'directory',
  }
}
