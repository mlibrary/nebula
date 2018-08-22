# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal HathiTrust server
#
# @example
#   include nebula::role::hathitrust
class nebula::role::hathitrust {

  include nebula::role::minimum

  if $facts['os']['release']['major'] == '9' {
    include nebula::profile::afs
    include nebula::profile::duo
    include nebula::profile::exim4
    include nebula::profile::grub
    include nebula::profile::ntp
    include nebula::profile::tiger
    include nebula::profile::users
    class { 'nebula::profile::networking':
      bridge => false,
      keytab => true
    }
  }

  include nebula::profile::dns::smartconnect
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::prospectors::ulib

}
