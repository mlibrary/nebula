# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# This only exports resources, so it doesn't directly affect anything
# that uses it. To import the resources,
#
#     concat { '/etc/ssh/ssh_known_hosts': }
#     Concat_fragment <<| tag == 'known_host_public_keys' |>>
#
# This will populate the host's system-wide known_hosts file with the
# public ssh keys from every host that uses this profile. Note that this
# only trusts the hosts; it does not actually grant access through a
# firewall or anything.
class nebula::profile::known_host_public_keys {
  $::ssh.each |$name, $key_obj| {
    $type = $key_obj["type"]
    $key = $key_obj["key"]

    @@concat_fragment { "known host ${::fqdn} ${name}":
      tag     => 'known_host_public_keys',
      target  => '/etc/ssh/ssh_known_hosts',
      content => "${::fqdn} ${type} ${key}\n",
    }
  }
}
