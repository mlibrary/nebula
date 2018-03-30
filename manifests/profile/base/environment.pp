# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::environment
#
# A description of what this class does
#
# @example
#   include nebula::profile::base::environment
class nebula::profile::base::environment (
  Hash $vars,
) {
  file { '/etc/profile.d/lit-cs.sh':
    content => template('nebula/profile/base/lit-cs.sh.erb'),
  }
}
