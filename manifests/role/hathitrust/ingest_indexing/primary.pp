# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Ingest and indexing servers for hathitrust.org
#
# @example
#   include nebula::role::hathitrust::ingest_indexing::primary
class nebula::role::hathitrust::ingest_indexing::primary {
  include nebula::role::hathitrust::ingest_indexing

  include nebula::profile::hathitrust::ingest_jobs
}
