# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::jira::prod
#
# JIRA production
#
# @example
#   include nebula::role::jira::prod
class nebula::role::jira::prod {
  include nebula::role::umich
  include nebula::profile::ruby
}
