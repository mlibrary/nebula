# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::app_host::prod
#
# Standalone application host including apache & mysql
#
# @example
#   include nebula::role::app_host::standalone
class nebula::role::app_host::standalone {
  include nebula::role::umich

  include nebula::profile::ruby
  include nebula::profile::nodejs

  include nebula::profile::named_instances::apache

  include nebula::profile::mysql
  include nebula::profile::redis
}
