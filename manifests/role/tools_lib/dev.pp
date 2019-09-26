# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Wrap nebula::role::tools_lib to allow for a dev vhost domain to be listed in the global heira data
#
# @example
#   include nebula::role::tools_lib::dev
class nebula::role::tools_lib::dev (
  String $domain
) {
  class { 'nebula::role::tools_lib':
    domain => $domain
  }
}
