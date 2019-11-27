# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Add Debian buster apt repo by code name
#
# @example
#   include nebula::profile::apt::buster
class nebula::profile::apt::buster {
  # pinning first so we don't install things we don't want
  apt::pin { 'buster':
    explanation => 'Deprioritize packages from Debian buster',
    release     => 'buster',
    priority    => -10,
    packages    => '*',
    before      => Apt::Source['buster']
  }

  # add apt repo
  apt::source { 'buster':
    location => lookup('nebula::profile::apt::mirror'),
    release  => 'buster',
    repos    => 'main contrib non-free',
  }
}
