# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust datasets server
#
# @example
#   include nebula::role::hathitrust::datasets
class nebula::role::hathitrust::datasets () {
  include nebula::role::hathitrust

  include nebula::profile::hathitrust::networking

  include nebula::profile::hathitrust::hosts

  class { 'nebula::profile::hathitrust::mounts':
    smartconnect_mounts => ['/htapps','/htprep'],
    readonly            => true,
  }

  include nebula::profile::hathitrust::rsync
  include nebula::profile::hathitrust::secure_rsync
}
