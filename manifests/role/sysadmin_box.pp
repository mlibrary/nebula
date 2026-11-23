# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::sysadmin_box
#
# Sysadmin messaround server
#
# @example
#   include nebula::role::sysadmin_box
class nebula::role::sysadmin_box {
  # The following 9 lines are just nebula::role::umich s/duo/okta/
  include nebula::role::minimum
  include nebula::profile::okta
  include nebula::profile::exim4
  include nebula::profile::grub
  include nebula::profile::ntp
  include nebula::profile::networking
  include nebula::profile::dns::standard
  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::configs::ulib

  include nebula::profile::users
  include nebula::profile::ruby
  include nebula::profile::root_ssh_private_keys
  include nebula::profile::prometheus::exporter::ipmi

  class { 'nebula::profile::puppet::query':
    ssl_group => 'sudo',
  }
}
