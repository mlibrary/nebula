# Copyright (c) 2018-2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# The minimum configuration for a host that logically belongs to Hathitrust.
#
# @example
#   include nebula::role::hathitrust
#   # you may also want to include:
#   include nebula::profile::hathitrust::networking
#   include nebula::profile::hathitrust::hosts
class nebula::role::hathitrust (
  String $internal_routing = '',
  Boolean $afs = true,
) {

  class { 'nebula::role::minimum':
    internal_routing => $internal_routing,
  }

  if $facts['os']['family'] == 'Debian' {
    include nebula::profile::krb5
    if $afs {
      include nebula::profile::afs
    }
    include nebula::profile::duo
    include nebula::profile::exim4
    include nebula::profile::grub
    include nebula::profile::ntp
    include nebula::profile::users
    class { 'nebula::profile::networking':
      bridge => false,
    }
  }

  include nebula::profile::dns::smartconnect
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::configs::ulib

}
