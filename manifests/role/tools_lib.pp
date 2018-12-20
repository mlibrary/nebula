# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# tools.lib.umich.edu
# stand up apache server w/ dependancies for atlassian tools
#
# @example
#   include nebula::role::tools_lib
class nebula::role::tools_lib {

  include nebula::profile::tools_lib::apache
  include nebula::profile::tools_lib::postgres
  #include nebula::profile::tools_lib::
  # need to include systemd unit files, is there an example for this?
  #include nebula::profile::
  #include nebula::profile::

}
