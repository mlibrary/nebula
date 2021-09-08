# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::apache
#
# Apache web server for hosting a Fulcrum server.
#
# This profile sets up Apache to serve the static assets and reverse proxy to
# the application via HTTPS. It also sets up the default virtual host to handle
# HTTP ACME challenges for Let's Encrypt and Certbot. We do not use the
# ssl_keypair profile because of this.

class nebula::profile::fulcrum::apache (
  String $servername = $::fqdn,
  Array $serveraliases = [],
  Array $metrics_cidrs = [],
) {
  class { 'apache':
    default_vhost => false,
  }

  apache::custom_config { 'badrobots':
    source => 'puppet:///apache/badrobots.conf'
  }

  apache::custom_config { 'listen-https':
    content => @(EOT)
      Listen 443
      | EOT
  }

  apache::vhost { "${servername}-http-acme":
    servername => $servername,
    port       => '80',
    docroot    => '/var/www/acme',
  }

  file { '/var/log/apache2/fulcrum':
    ensure => 'directory'
  }

  file { '/etc/apache2/sites-available/fulcrum-https.conf':
    ensure  => 'present',
    content => template('nebula/profile/fulcrum/vhost.conf.erb'),
    notify  => Class['apache::service'],
  }

  class { 'nebula::profile::letsencrypt':
    overrides => {
      'renew_cron_ensure' => 'present',
    }
  }

  letsencrypt::certonly { $servername:
    domains       => [$servername],
    plugin        => 'webroot',
    webroot_paths => ['/var/www/acme'],
  }

  include nebula::profile::networking::firewall::http_datacenters
}
