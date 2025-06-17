# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::search::solr {
  include nebula::role::minimum

  include nebula::profile::ntp
  include nebula::profile::unattended_upgrades
}
