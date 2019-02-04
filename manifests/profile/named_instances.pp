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
  String      $puma_wrapper,
  Hash[String,Hash] $instances = {}
) {

  class { 'nebula::profile::named_instances::puma_wrapper':
    path        => $puma_wrapper,
    puma_config => $fauxpaas_puma_config,
    rbenv_root  => lookup('nebula::profile::ruby::install_dir'),
  }

  $defaults = {
    puma_wrapper    => $puma_wrapper,
    pubkey          => $fauxpaas_pubkey,
    puma_config     => $fauxpaas_puma_config,
  }

  create_resources(nebula::named_instance, $instances, $defaults)
}
