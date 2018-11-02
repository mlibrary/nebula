# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::unison
#
# Install unison dependencies for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::unison
class nebula::profile::hathitrust::unison () {
  package { 'unison': }
}
