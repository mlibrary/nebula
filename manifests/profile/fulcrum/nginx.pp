# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Set up NGINX as the web server and reverse proxy for Fulcrum. Also manages
# SSL certificates with Let's Encrypt.
class nebula::profile::fulcrum::nginx (
  Integer $port = 3000,
  String $server_name = $::fqdn,
  String $webroot = '/var/www/acme',
) {
  include nginx

  $letsencrypt_directory = $::letsencrypt_directory[$server_name]

  if $letsencrypt_directory {
    nginx::resource::server { 'fulcrum':
      server_name          => [$server_name],
      www_root             => '/home/fulcrum/app/current/public',
      use_default_location => false,
      listen_port          => 443,
      ssl                  => true,
      ssl_cert             => "${letsencrypt_directory}/fullchain.pem",
      ssl_key              => "${letsencrypt_directory}/privkey.pem",
      require              => Nebula::Cert[$server_name],
    }

    nginx::resource::location { 'fulcrum-static':
      server    => 'fulcrum',
      ssl       => true,
      ssl_only  => true,
      location  => '/',
      try_files => ['$uri', '$uri/', '@proxy'],
      priority  => 450,
    }

    # Set up derivatives for offloading (with the 'internal' flag)
    nginx::resource::location { 'fulcrum-derivatives':
      server         => 'fulcrum',
      ssl            => true,
      ssl_only       => true,
      location       => '/derivatives',
      location_alias => '/var/local/fulcrum/data/derivatives',
      internal       => true,
      priority       => 451,
    }

    nginx::resource::location { 'fulcrum-proxy':
      server           => 'fulcrum',
      ssl              => true,
      ssl_only         => true,
      location         => '@proxy',
      proxy            => "http://localhost:${port}",
      proxy_set_header => [
        'X-Sendfile-Type X-Accel-Redirect',
        'X-Accel-Mapping /var/local/fulcrum/data/derivatives=/derivatives',
      ],
      priority         => 452,
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

  cron { 'restart nginx weekly to keep SSL keys up to date':
    # This will run once per week sometime between midnight and 4:00 in
    # the morning.
    weekday => fqdn_rand(7),
    hour    => fqdn_rand(3),
    minute  => fqdn_rand(60),
    command => '/bin/systemctl restart nginx',
  }

  include nebula::profile::networking::firewall::http_datacenters
}
