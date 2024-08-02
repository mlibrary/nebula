# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::discovery::configure_targets (
  Integer $port,
) {
  case $facts["mlibrary_ip_addresses"] {
    Hash[String, Array[String]]: {
      $all_public_addresses = $facts["mlibrary_ip_addresses"]["public"]
      $all_private_addresses = $facts["mlibrary_ip_addresses"]["private"]
    }

    default: {
      $all_public_addresses = [$::ipaddress]
      $all_private_addresses = []
    }
  }

  Concat_fragment <<| tag == $title |>>

  $all_public_addresses.each |$address| {
    @@firewall { "${title} ${::hostname} ${address}":
      tag    => "${title}_public",
      dport  => $port,
      source => $address,
      proto  => "tcp",
      state  => "new",
      action => "accept",
    }
  }

  $all_private_addresses.each |$address| {
    @@firewall { "${title} ${::hostname} ${address}":
      tag    => "${title}_private",
      dport  => $port,
      source => $address,
      proto  => "tcp",
      state  => "new",
      action => "accept",
    }
  }
}
