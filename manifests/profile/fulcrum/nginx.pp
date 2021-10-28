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
  class { 'nginx':
    manage_repo    => true,
    package_source => 'nginx-stable',
  }

  ensure_packages([
    'nginx-module-shibboleth',
    'nginx-module-headersmore',
  ])

  $letsencrypt_directory = $::letsencrypt_directory[$server_name]

  $networks = lookup('nebula::profile::networking::firewall::http_datacenters::networks')
  $allow = $networks.flatten.map |$network| { $network['block'] }

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

    nginx::resource::location { 'fulcrum-root':
      server         => 'fulcrum',
      ssl            => true,
      ssl_only       => true,
      location       => '/',
      location_allow => $allow,
      location_deny  => ['all'],
      # Check for static file under public/ before proxying everything else
      try_files      => ['$uri', '$uri/', '@proxy'],
      priority       => 450,
    }

    # Set up derivatives for offloading (with the 'internal' flag)
    nginx::resource::location { 'fulcrum-derivatives':
      server         => 'fulcrum',
      ssl            => true,
      ssl_only       => true,
      location       => '/derivatives',
      location_alias => '/var/local/fulcrum/data/derivatives',
      internal       => true,
      priority       => 460,
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
        'X-Forwarded-Host $host',
        'X-Forwarded-Proto $scheme',
      ],
      priority         => 470,
    }

    # Metrics are exported on a separate port by yabeda-prometheus
    # TODO: The port should be exposed directly to Prometheus or require auth
    nginx::resource::location { 'fulcrum-metrics':
      server         => 'fulcrum',
      ssl            => true,
      ssl_only       => true,
      location       => '/metrics',
      proxy          => 'http://localhost:9394/metrics',
      priority       => 480,
    }

    # The authorizer is the back-channel for authenticating with the SP
    nginx::resource::location { 'fulcrum-shibauthorizer':
      server   => 'fulcrum',
      ssl      => true,
      ssl_only => true,
      location => '/shibauthorizer',
      internal => true,
      include  => ['fastcgi_params'],
      fastcgi  => 'unix:/var/run/shibauthorizer.sock',
      priority => 490,
    }

    # The responder is the public interface to the SP
    nginx::resource::location { 'fulcrum-shibresponder':
      server   => 'fulcrum',
      ssl      => true,
      ssl_only => true,
      location => '/Shibboleth.sso',
      include  => ['fastcgi_params'],
      fastcgi  => 'unix:/var/run/shibresponder.sock',
      priority => 500,
    }

    $shib_config = {
    }

    # Fulcrum checks Shibboleth headers and establishes an app session at /shib_session
    nginx::resource::location { 'fulcrum-shib-session':
      server              => 'fulcrum',
      ssl                 => true,
      ssl_only            => true,
      location            => '/shib_session',
      location_allow      => $allow,
      location_deny       => ['all'],
      include             => ['shib_clear_headers', 'shib_proxy_headers'],
      location_cfg_append => {
        'more_clear_input_headers' => "'displayName' 'mail' 'persistent-id'",
        'shib_request'             => '/shibauthorizer',
      },
      proxy               => "http://localhost:${port}",
      proxy_set_header    => [
        'X-Forwarded-Host $host',
        'X-Forwarded-Proto $scheme',
      ],
      priority            => 510,
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

  file { '/etc/nginx/shib_clear_headers':
    source => 'puppet:///modules/nebula/nginx-shibboleth/shib_clear_headers',
  }

  file { '/etc/nginx/shib_proxy_headers':
    source => 'puppet:///modules/nebula/nginx-shibboleth/shib_proxy_headers',
  }

  file { '/etc/nginx/modules-enabled/shibboleth.conf':
    content => template('nebula/profile/fulcrum/nginx-shibboleth.conf.erb'),
  }

  file { '/etc/nginx/modules-enabled/headersmore.conf':
    content => template('nebula/profile/fulcrum/nginx-headersmore.conf.erb'),
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

  firewall { "200 HTTPS: public":
    proto  => 'tcp',
    dport  => 443,
    state  => 'NEW',
    action => 'accept',
  }
}
