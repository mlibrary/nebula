# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal server
#
# @example
#   include nebula::role::minimum
class nebula::role::minimum (Boolean $manage_firewall_resources = false)
{
  if $facts['os']['name'] == 'Debian' {
    include nebula::profile::base
    include nebula::profile::work_around_puppet_bugs

    if $facts['os']['release']['major'] == '9' {
      if($manage_firewall_resources) {
        include nebula::profile::networking::firewall
      } else {
        include nebula::profile::base::firewall::ipv4
      }
      include nebula::profile::apt
      include nebula::profile::authorized_keys
      include nebula::profile::vim
    }
  }
}
