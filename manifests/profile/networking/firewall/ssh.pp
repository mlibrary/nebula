# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::firewall::ssh
#
# Manage firewall (iptables) settings for SSH
#
# @example
#   include nebula::profile::networking::firewall::ssh
class nebula::profile::networking::firewall::ssh (
  Array $networks = [],
) {

  $networks.flatten.each |$network| {
    firewall { "100 SSH: ${network['name']}":
      proto  => 'tcp',
      dport  => 22,
      source => $network['block'],
      state  => 'NEW',
      action => 'accept',
    }

    @firewall { "200 kubectl: ${network['name']}":
      tag    => 'listen_for_kubectl',
      proto  => 'tcp',
      dport  => 6443,
      source => $network['block'],
      state  => 'NEW',
      action => 'accept',
    }
  }
}
