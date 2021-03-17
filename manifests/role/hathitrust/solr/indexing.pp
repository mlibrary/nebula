# Copyright (c) 2019-2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust solr indexing
#
# @example
#   include nebula::role::hathitrust::solr::indexing
class nebula::role::hathitrust::solr::indexing {
  include nebula::role::hathitrust::solr
  include nebula::profile::ruby
  include nebula::profile::hathitrust::slip
}
