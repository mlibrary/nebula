# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::discovery::listen_on_port (
  String $concat_target,
  String $concat_content,
  Optional[String] $concat_order = undef,
  Boolean $require_public_ip = false,
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

  if $require_public_ip or $all_private_addresses == [] {
    if $all_public_addresses == [] {
      fail("At least one IP address is required")
    } else {
      $the_main_ip_address = $all_public_addresses[0]
      Firewall <<| tag == "${title}_public" |>>
    }
  } else {
    $the_main_ip_address = $all_private_addresses[0]
    Firewall <<| tag == "${title}_private" |>>
  }

  if $concat_order == undef {
    @@concat_fragment { "${title} ${::hostname}":
      tag     => $title,
      target  => $concat_target,
      content => regsubst($concat_content, "\\\$IP_ADDRESS", $the_main_ip_address, "G"),
    }
  } else {
    @@concat_fragment { "${title} ${::hostname}":
      tag     => $title,
      target  => $concat_target,
      order   => $concat_order,
      content => regsubst($concat_content, "\\\$IP_ADDRESS", $the_main_ip_address, "G"),
    }
  }
}
