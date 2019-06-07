# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::cron_runner
#
# Role for host that has ruby installed and can run a list of cron jobs as
# configured in hiera. These cron jobs should be things that have only network
# dependencies -- i.e. no local filesystem dependencies. While the cron jobs
# can be configured via hiera, currently, the code to run must be installed
# manually.
#
# Any users the cron jobs run as should be in the 'cron' group to ensure they
# get created on this node.
#
# @param crons Resource definitions for cron jobs to configure on this node.
#
# @example
#   include nebula::role::cron_runner
class nebula::role::cron_runner(
  Hash $crons = {}
) {
  include nebula::role::umich
  include nebula::profile::ruby
  include nebula::profile::nodejs

  nebula::usergroup { 'cron': }
  realize User['spot']
  create_resources(cron,$crons)
}
