# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tiger
#
# Manage tiger.
#
# @example
#   include nebula::profile::tiger
class nebula::profile::tiger {

  package { 'tiger': }

  file_line { 'tiger dormant limit':
    path  => '/etc/tiger/tigerrc',
    line  => 'Tiger_Dormant_Limit=0',
    match => '^Tiger_Dormant_Limit',
  }
}
