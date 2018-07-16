# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal aws server
#
# @example
#   include nebula::role::aws
class nebula::role::aws {

  include nebula::profile::base
  include nebula::profile::aws::filesystem

  if $facts['os']['release']['major'] == '9' {
    include nebula::profile::apt
    include nebula::profile::authorized_keys
    include nebula::profile::exim4
    include nebula::profile::ntp
    include nebula::profile::tiger
    include nebula::profile::vim
    include nebula::profile::aws::filesystem
    class { 'nebula::profile::networking':
      bridge => false,
      keytab => false
    }
  }

  include nebula::profile::dns::standard
  include nebula::profile::elastic::metricbeat

}
