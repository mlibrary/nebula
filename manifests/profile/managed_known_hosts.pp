# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::managed_known_hosts (
  Hash[String, Hash[String, String]] $static_host_keys = {},
) {
  concat { '/etc/ssh/ssh_known_hosts': }

  # See nebula::profile::known_host_public_keys
  Concat_fragment <<| tag == 'known_host_public_keys' |>>

  $static_host_keys.each |$host, $public_keys| {
    $public_keys.each |$type, $key| {
      concat_fragment { "static known host ${host} ${type}":
        tag     => 'known_host_public_keys',
        target  => '/etc/ssh/ssh_known_hosts',
        content => "${host} ${type} ${key}\n",
      }
    }
  }
}
