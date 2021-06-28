# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::hathitrust::vmhost
#
# VM Host. A VM host should probably do nothing other than host VMs.
#
# This role is for a HathiTrust VM host that has its vm images somewhere that
# requires SmartConnect DNS to be set up.
#
# @example
#   include nebula::role::hathitrust::vmhost
class nebula::role::hathitrust::vmhost {
  # This is a mashup of nebula::role::hathitrust and nebula::role::vmhost that
  #  - includes vm hosting (vmhost::host)
  #  - includes smartconnect
  #  - doesn't include AFS or human users

  include nebula::role::minimum

  if $facts['os']['family'] == 'Debian' and $::lsbdistcodename != 'jessie' {
    include nebula::profile::duo
    include nebula::profile::exim4
    include nebula::profile::grub
    include nebula::profile::ntp
    class { 'nebula::profile::networking':
      bridge => true,
    }
  }

  include nebula::profile::dns::smartconnect
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::prospectors::ulib

  include nebula::profile::vmhost::host
}
