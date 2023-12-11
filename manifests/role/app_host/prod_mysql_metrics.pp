# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Application host (development or development-like, with private network configured).
#
# Be sure to set the networking::private details for the host in hiera.
#
# @example
#   include nebula::role::app_host::prod
class nebula::role::app_host::prod_mysql_metrics {
  include nebula::role::app_host::prod
  include nebula::profile::prometheus::exporter::mysql
}
