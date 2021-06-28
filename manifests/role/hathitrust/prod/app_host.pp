# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Slurpee-3, squishee-3
class nebula::role::hathitrust::prod::app_host {
  include nebula::role::hathitrust::prod
  include nebula::profile::ruby
}
