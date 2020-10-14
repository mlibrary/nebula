# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust development/prep MySQL
#
# @example
#   include nebula::role::hathitrust::dev::mysql
class nebula::role::hathitrust::dev::mysql {
  include nebula::role::hathitrust::dev
  include nebula::profile::prometheus::exporter::mysql
}
