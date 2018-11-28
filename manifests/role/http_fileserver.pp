# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::http_fileserver
#
# Role for a machine that serves a single directory of static files via
# http/https
#
# @example
#   include nebula::role::http_fileserver
class nebula::role::http_fileserver {
  include nebula::role::umich_new_firewall

  include nebula::profile::http_fileserver
}
