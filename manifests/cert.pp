# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

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
