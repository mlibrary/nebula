# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::unison
#
# Install unison dependencies
#
# @example
#   include nebula::profile::hathitrust::unison
class nebula::profile::unison (
  Array $servers = [],
  Array $clients = []
) {
  include nebula::profile::logrotate

  logrotate::rule { 'unison':
    path          => '/var/log/unison.log',
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
