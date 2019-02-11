# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::unison::client
#
# Configure Unison file synchronization (server)
#
# @example
#   include nebula::profile::unison::client
class nebula::profile::unison::client (
  String $home = '/root',
) {

  ensure_packages(['unison'])

  file { "${home}/.unison":
    ensure => 'directory'
  }

  file { '/usr/local/bin/unisonsync':
    content => template('nebula/profile/unison/client/unisonsync.erb'),
    mode    => '0755'
  }

}
