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

  # This fact is set by the letsencrypt module. If letsencrypt has
  # created a cert, then this will be set to the directory that cert
  # exists in. If the cert doesn't exist yet, this will be null.
  $letsencrypt_directory = $::letsencrypt_directory[$server_name]

  if $letsencrypt_directory {
    # Only serve the HTTPS site if the cert aleady exists.
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

  # Create and manage the cert for this server name. This assumes that
  # we're serving HTTP requests to the $webroot directory, which is
  # served by nginx below.
  nebula::cert { $server_name:
    webroot => $webroot,
    require => Nginx::Resource::Server['letsencrypt-webroot'],
  }

  # Serve HTTP requests to the webroot directory.
  nginx::resource::server { 'letsencrypt-webroot':
    server_name => [$server_name],
    listen_port => 80,
    www_root    => $webroot,
    require     => File[$webroot],
  }

  # Ensure that the webroot directory exists.
  file { $webroot:
    ensure => 'directory',
  }

  cron { 'restart nginx weekly to keep SSL keys up to date':
    # This will run once per week sometime between midnight and 4:00 in
    # the morning.
    weekday => fqdn_rand(7),
    hour    => fqdn_rand(3),
    minute  => fqdn_rand(60),
    command => '/bin/systemctl restart nginx',
  }
}
