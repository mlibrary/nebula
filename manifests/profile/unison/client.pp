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
  Integer $watchdog_sec = 7200,
  String $home = '/root',
) {

  ensure_packages(['unison'])

  file { "${home}/.unison":
    ensure => 'directory'
  }

  # /etc/systemd/system/moxiesync.service
  file { '/etc/systemd/system/unison-client@.service':
    content =>  template('nebula/profile/unison/client/unison-client.service.erb')
  }

  file { '/usr/local/bin/unisonsync':
    content => template('nebula/profile/unison/client/unisonsync.erb'),
    mode    => '0755'
  }

}
