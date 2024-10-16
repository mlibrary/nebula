# Copyright (c) 2018-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# The base profile of one of our hosts. Every role should build on this.
#
# @example
#   include nebula::role::minimum
class nebula::role::minimum (
  String $internal_routing = '',
) {
  if $facts['os']['family'] == 'Debian' {
    include nebula::profile::base
    include nebula::profile::prometheus::exporter::node
    include nebula::profile::authorized_keys
    include nebula::profile::known_host_public_keys
    include nebula::profile::falcon

    class { 'nebula::profile::networking::firewall':
      internal_routing => $internal_routing,
    }

    include nebula::profile::networking::firewall::private_ssh
    include nebula::profile::apt
    include nebula::profile::vim
  }
}
