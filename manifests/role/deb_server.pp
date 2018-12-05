# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::deb_server
#
# Role for a machine that serves a repository of debs via http/https
#
# @example
#   include nebula::role::deb_server
class nebula::role::deb_server {
  include nebula::role::umich_new_firewall

  include nebula::profile::http_fileserver
  include nebula::profile::deb_signing
}
