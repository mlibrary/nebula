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
  String      $pubkey,
  String      $puma_config,
  String      $puma_wrapper,
  Boolean     $create_databases = true,
  Hash[String,Hash] $instances = {}
) {

  class { 'nebula::profile::named_instances::puma_wrapper':
    path        => $puma_wrapper,
    puma_config => $puma_config,
    rbenv_root  => lookup('nebula::profile::ruby::install_dir'),
  }

  $instances.each |$instance| {
    Nebula::Named_instance::App <<| title == $instance |>>
    Nebula::Named_instance::Solr_core <<| instance == $instance |>>
  }
}
