# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust prep application host
#
# @example
#   include nebula::role::hathitrust::prep_app_host
class nebula::role::hathitrust::prep_app_host {
  class { 'nebula::role::hathitrust::prep':
    internal_routing => 'docker',
  }

  include nebula::profile::python
  include nebula::profile::ruby
  include nebula::profile::docker
  include nebula::profile::tsm
}
