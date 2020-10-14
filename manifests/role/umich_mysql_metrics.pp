# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Umich Role with prometheus mysql exporter
#
# @example
#   include nebula::role::umich
class nebula::role::umich_mysql_metrics {
  include nebula::role::umich
  include nebula::profile::prometheus::exporter::mysql
}
