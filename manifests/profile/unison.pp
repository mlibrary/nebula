# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::unison
#
# Install unison dependencies
#
# @example
#   include nebula::profile::unison
class nebula::profile::unison (
  Array $servers = [],
  Array $clients = [],
  Hash $nfs_mounts = {},
  Hash $cifs_mounts = {},
  Hash $cifs_defaults = {}
) {
  include nebula::profile::logrotate

  create_resources(nebula::nfs_mount,$nfs_mounts)
  create_resources(nebula::cifs_mount,$cifs_mounts,$cifs_defaults)

  logrotate::rule { 'unison':
    path          => '/var/log/unison*.log',
    rotate        => 7,
    rotate_every  => 'day',
    missingok     => true,
    ifempty       => false,
    delaycompress => true,
    compress      => true,
  }

  $servers.each |String $instance| {
    nebula::unison::server { $instance:
      * => lookup("nebula::unison::${instance}")
    }
  }

  $clients.each |String $instance| {
    Nebula::Unison::Client <<| title == $instance |>>
  }
}
