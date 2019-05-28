# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::named_instances
#
# This profile provisions and manages zero or more named instances. It
# uses a list of instance names passed as a parameter to discover and
# actualize resources exported by the named_instance defined type.
#
# @param pubkey Common. The public key that the moku user will use to connect
#   to this host.
# @param puma_wrapper Common. The absolute path of the puma wrapper.
# @param puma_config Common. The relative path of the puma configuration file in
#   the deployed application.
# @param create_databases Whether or not to provision a database
# @param instances List of named instances (their name as strings)
#
# @example
#   include nebula::profile::named_instances
class nebula::profile::named_instances (
  String      $pubkey,
  String      $puma_config,
  String      $puma_wrapper,
  Boolean     $create_databases = true,
  Array[String] $instances = []
) {

  class { 'nebula::profile::named_instances::puma_wrapper':
    path        => $puma_wrapper,
    puma_config => $puma_config,
    rbenv_root  => lookup('nebula::profile::ruby::install_dir'),
  }

  # Use the passed instance names to find the exported instance configuration
  # resources from each of the named_instance resources.
  $instances.each |$instance| {
    Nebula::Named_instance::App <<| title == $instance |>>
    Nebula::Named_instance::Solr_core <<| instance == $instance |>>
  }

  # we don't create or manage this, but puppet needs to know about it in order
  # to notify it
  ensure_resource('service', 'rsyslog', { 'hasrestart' => true })

  file { '/etc/rsyslog.d/drop-rbenv.conf':
    content => ':programname, isequal, "rbenv" ~',
    notify  => Service['rsyslog']
  }
}

