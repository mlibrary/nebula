# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Minimal aws with prometheus mysql exporter
#
# @example
#   include nebula::role::aws
class nebula::role::aws::mysql_metrics {
  include nebula::role::aws
  include nebula::profile::prometheus::exporter::mysql
}
