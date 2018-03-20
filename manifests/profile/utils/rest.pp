# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::utils::rest
#
# Install curl and jq; keep them up-to-date.
#
# @example
#   include nebula::profile::utils::rest
class nebula::profile::utils::rest {
  package { 'curl': }
  package { 'jq': }
}
