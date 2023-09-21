# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::alma_integrations {
  include nebula::role::umich
  include nebula::profile::alma_integrations
  include nebula::profile::cron_runner
}
