# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::users
#
# Provision users and groups.
#
# @example
#   include nebula::profile::users
class nebula::profile::users {
  nebula::usergroup { 'sudo': }
}
