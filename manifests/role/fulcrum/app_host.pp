# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Role for a host that runs the webapp portions of Fulcrum. All of the
# backing services are expected to be elsewhere.

class nebula::role::fulcrum::app_host {
  include nebula::role::minimum
  include nebula::profile::ruby
  include nebula::profile::fulcrum::base
  include nebula::profile::fulcrum::hosts
  include nebula::profile::fulcrum::symlinks
  include nebula::profile::fulcrum::mounts
  include nebula::profile::fulcrum::app
  include nebula::profile::fulcrum::logrotate
}
