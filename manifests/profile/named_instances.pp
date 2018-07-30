# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::named_instances
#
# Manage named instances
#
# @param instances List of named instances
#
# @example
#   include nebula::profile::named_instances
class nebula::profile::named_instances (
  String      $fauxpaas_pubkey,
  String      $fauxpaas_puma_config,
  Hash        $instances = {},
) {
  $instances.each |$name, $instance| {
    nebula::named_instance { $name:
      path        => $instance['path'],
      uid         => $instance['uid'],
      gid         => $instance['gid'],
      users       => $instance['users'],
      subservices => $instance['subservices'],
      pubkey      => $fauxpaas_pubkey,
      puma_config => $fauxpaas_puma_config,
    }
  }
}
