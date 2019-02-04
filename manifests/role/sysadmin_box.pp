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
  include nebula::role::umich
  include nebula::profile::ruby

  class { 'nebula::profile::puppet::query':
    ssl_group => 'sudo',
  }

  # Generate app instance configs; not yet for distribution
  Nebula::Profile::Proxied_app <<| |>>
}
