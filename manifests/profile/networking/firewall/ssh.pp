# Copyright (c) 2018-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::firewall::ssh
#
# Manage firewall (iptables) settings for SSH
#
# @example
#   include nebula::profile::networking::firewall::ssh
class nebula::profile::networking::firewall::ssh {
  if is_publicly_accessible() {
    nebula::exposed_port { '100 SSH':
      port  => 22,
      block => 'umich::networks::all_trusted_machines',
    }
  } else {
    nebula::exposed_port { '100 SSH':
      port  => 22,
      block => 'umich::networks::private_bastion_hosts',
    }
  }
}
