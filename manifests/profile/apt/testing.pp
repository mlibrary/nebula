# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Add Debian testing apt repo by code name
#
# @example
#   include nebula::profile::apt::testing
class nebula::profile::apt::testing {
  # pinning first so we don't install things we don't want
  apt::pin { 'testing':
    explanation => 'Deprioritize packages from Debian Testing',
    release     => 'testing',
    priority    => -10,
    packages    => '*',
    before      => Apt::Source['testing']
  }

  # add apt repo
  apt::source { 'testing':
    location => lookup('nebula::profile::apt::mirror'),
    release  => 'testing',
    repos    => 'main contrib non-free',
  }
}
