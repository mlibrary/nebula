# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Puppet Master
#
# @example
#   DEPRECATED
#   include nebula::role::puppet::master
class nebula::role::puppet::master {
  include nebula::role::umich
  include nebula::profile::puppet::master
  include nebula::profile::certbot_route53
  include nebula::profile::certbot_cloudflare
  include nebula::profile::certbot_incommon

  # FIXME because there's also a git repo
  include nebula::profile::krb5
  include nebula::profile::afs
  include nebula::profile::users
}
