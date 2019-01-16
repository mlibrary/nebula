# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::unison::server
#
# Configure Unison file synchronization (server)
#
# @example
#   include nebula::profile::unison::server
class nebula::profile::unison::server (
  String $home = '/root'
) {

  ensure_packages(['unison'])

  # /etc/systemd/system/moxiesync.service
  file { '/etc/systemd/system/unison@.service':
    content =>  template('nebula/profile/unison/server/unison.service.erb')
  }
}
