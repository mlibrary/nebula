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
  String $servername = $::fqdn
) {
  class { 'nebula::profile::letsencrypt':
    overrides => {
      config => {
        'server' => 'https://acme-staging-v02.api.letsencrypt.org/directory',
      }
    }
  }

  class { 'apache':
    default_vhost => false,
  }

  apache::vhost { "HTTP ACME: ${servername}":
    servername => $servername,
    port       => '80',
    docroot    => '/var/www/acme',
  }

  letsencrypt::certonly { "Certificate: ${servername}":
    domains       => [$servername],
    plugin        => 'webroot',
    webroot_paths => ['/var/www/acme'],
  }

  include nebula::profile::networking::firewall::http_datacenters
}
