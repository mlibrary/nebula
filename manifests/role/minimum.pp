# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal server
#
# @example
#   include nebula::role::minimum
class nebula::role::minimum ()
{
  if $facts['os']['name'] == 'Debian' {
    include nebula::profile::base
    include nebula::profile::work_around_puppet_bugs

    if $facts['os']['release']['major'] == '9' {
      include nebula::profile::networking::firewall
      include nebula::profile::apt
      include nebula::profile::authorized_keys
      include nebula::profile::vim
    }
  }
}
