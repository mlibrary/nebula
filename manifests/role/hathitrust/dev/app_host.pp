# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust development application host
#
# @example
#   include nebula::role::hathitrust::dev::app_host
class nebula::role::hathitrust::dev::app_host {
  include nebula::role::hathitrust::dev
  include nebula::profile::named_instances
}
