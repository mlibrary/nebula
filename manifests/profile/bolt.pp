# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::bolt {
  include nebula::virtual::users

  package { 'puppet-bolt': }

  $users = lookup('nebula::profile::authorized_keys::ssh_keys').keys

  $users.each |$user| {
    realize User[$user]
  }
}
