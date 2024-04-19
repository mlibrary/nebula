# Copyright (c) 2018-2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust production
#
# DEPRECATED - only for "classic" solr servers
#
# @example
#   include nebula::role::hathitrust::prod
class nebula::role::hathitrust::prod {
  include nebula::role::hathitrust
  include nebula::profile::hathitrust::slip
  include nebula::profile::hathitrust::solr6::classic
}
