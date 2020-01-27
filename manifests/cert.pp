# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Let's Encrypt Certificate
#
# This manages a single letsencrypt key/chain. It mostly just uses a
# letsencrypt::certonly resource, but it also ensures the letsencrypt
# profile is loaded.
#
# Set the title to the domain the cert is for.
#
# @param additional_domains An optional array of additional domains the
#   cert covers
# @param webroot Without this, every time we renew the cert, it'll use a
#   standalone http server. If we already have something else set up, we
#   should pass a path to the `/` directory (e.g. `/var/www`). This can
#   also be an array in the case were there are multiple domains covered
#   by the cert.
#
# @example Single domain with webroot
#   nebula::cert { 'mydomain.com':
#     webroot => '/var/www',
#   }
#
# @example Five domains with differing webroot paths
#   nebula::cert { 'primary.com':
#     additional_domains => ['secondary.com', 'third.com', 'third.net', 'third.org'],
#     webroot            => ['/www/primary', '/www/secondary', '/www/third'],
#   }
define nebula::cert (
  Array[String] $additional_domains = [],
  Variant[Array[String[1]], String[1]] $webroot = [],
) {
  require nebula::profile::letsencrypt

  if $webroot == [] {

    letsencrypt::certonly { $title:
      domains     => [$title] + $additional_domains,
      manage_cron => true,
    }

  } else {

    if $webroot =~ Array {
      $webroot_paths = $webroot
    } else {
      $webroot_paths = [$webroot]
    }

    letsencrypt::certonly { $title:
      domains       => [$title] + $additional_domains,
      manage_cron   => true,
      plugin        => 'webroot',
      webroot_paths => $webroot_paths,
    }

  }
}
