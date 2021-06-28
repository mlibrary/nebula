# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::deploy_host
#
# The host from which developers deploy applications. This is the
# moku server.
#
# @example
#   include nebula::role::deploy_host
class nebula::role::deploy_host {
  if $::lsbdistcodename == 'jessie' {
    include nebula::role::umich

    include nebula::profile::ruby
    include nebula::profile::nodejs
    include nebula::profile::moku
  } else {
    class { 'nebula::role::umich':
      internal_routing => 'docker',
    }

    include nebula::profile::ruby
    include nebula::profile::nodejs
    include nebula::profile::moku
    include nebula::profile::krb5
    include nebula::profile::afs
    include nebula::profile::users
    include nebula::profile::docker
  }
}
