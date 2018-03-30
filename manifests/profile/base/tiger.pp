# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::tiger
#
# A description of what this class does
#
# @example
#   include nebula::profile::base::tiger
class nebula::profile::base::tiger {
  file_line { 'tiger dormant limit':
    path  => '/etc/tiger/tigerrc',
    line  => 'Tiger_Dormant_Limit=0',
    match => '^Tiger_Dormant_Limit',
  }
}
