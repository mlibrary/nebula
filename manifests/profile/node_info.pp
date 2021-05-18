# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::node_info
#
# Make available node_info python script for dumping basic information on
# puppet and machine configuation (currently only supporting AWS) information
##
# @example
#   include nebula::profile::node_info
class nebula::profile::node_info () {

  cron { 'log anon cron':
    command => '/bin/cp /opt/puppetlabs/puppet/cache/state/last_run_summary.yaml /var/last_run_summary.yaml',
    user    => 'root',
    minute  => '*/5'
  }

  file { '/usr/local/bin/node_info':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/nebula/bin/node_info'
  }

}
