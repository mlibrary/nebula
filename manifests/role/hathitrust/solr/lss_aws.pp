# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust solr search on AWS. The time zone and core data paths must be
# configured via Hiera.
#
# @example
#   include nebula::role::hathitrust::solr::lss_aws
class nebula::role::hathitrust::solr::lss_aws {
  include nebula::role::aws
  include nebula::profile::hathitrust::solr_lss
  include nebula::profile::node_info
}
