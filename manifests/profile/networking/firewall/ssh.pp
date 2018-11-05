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
  Array $blocks,
  Array $ranges,
) {
  $blocks.each |$block| {
    firewall { "100 SSH: ${block['name']}":
      proto     => 'tcp',
      dport     => 22,
      source    => $block['source'],
      tcp_flags => 'SYN,RST,ACK,FIN SYN', # equivalent to --syn
      action    => 'accept',
    }
  }

  $ranges.each |$range| {
    firewall { "100 SSH: ${range['name']}":
      proto     => 'tcp',
      dport     => 22,
      src_range => $range['src_range'],
      tcp_flags => 'SYN,RST,ACK,FIN SYN', # equivalent to --syn
      action    => 'accept',
    }
  }
}
