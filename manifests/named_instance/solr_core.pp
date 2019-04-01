
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Initializes a solr core for a named instance. The config for the core is
# located under the deployed named instance.  If the named instance has not
# previously been deployed, initializes the core with a default config.
#
# @param instance_path The path to the named instance
#
# @param instance The name of the named instance; assumed to also be the
# username and group the application runs as to be used as the owner & group
# for the solr directory.
#
# @param host The hostname of the solr server
#
# @param port The port of the solr server
#
# @param index The key by which this core will be referenced under
# infrastructure.solr. in the infrastructure configuration.
#
# @param core_home The path under which to physically create the core
#
# @param solr_home The SOLR_HOME for the solr instance; the core will be symlinked here
#
# @param config_dir The directory under the 'solr' directory of the deployed
# named instance which contains the solr config
#
# @param default_config The path to a default solr configuration directory to
# use, if the application has not previously been deployed
#
# @param solr_user The user the solr application runs as, for ownership of the
# core directory
#
# @param solr_group The group the solr application runs as, for ownership of
# the core directory
#
# The example creates a solr core called 'myapp-staging-mycore' on the solr
# server localhost:8081 with the core located under
# '/apphome/solr/cores/myapp-staging-mycore' with a config from
# /apphome/myapp-staging/current/solr/conf. If that directory does not exist, it
# will create it as a symlink to the given default config.

# @example
#   nebula::named_instance::solr_core ( 'myapp-staging-mycore':
#     instance_path  => '/apphome/myapp-staging',
#     instance       => 'myapp-staging',
#     host           => 'localhost',
#     port           => '8081',
#     core_home      => '/apphome/solr/cores',
#     solr_home      => '/var/lib/solr/home',
#     config_dir     => 'conf',
#     default_config => '/opt/solr-6.1.0/server/solr/configsets/basic_configs/conf'
#   )

define nebula::named_instance::solr_core (
  String $instance_path,
  String $instance,
  Integer $index,
  String $host,
  Integer $port,
  String $core_home = lookup('nebula::named_instance::solr_core::core_home'),
  String $solr_home = lookup('nebula::named_instance::solr_core::solr_home'),
  String $config_dir = 'conf',
  String $default_config = lookup('nebula::named_instance::solr_core::default_config'),
  String $solr_user = 'solr',
  String $solr_group = 'solr'
) {

  $real_core_path = "${core_home}/${title}"
  $solr_core_path = "${solr_home}/${title}"

  # ensure the named instance has some solr config we can use
  ensure_resource('file',
    [
      "${instance_path}/releases",
      "${instance_path}/releases/0",
      "${instance_path}/releases/0/solr"
    ],
    {
      ensure => 'directory',
      mode   => '2775',
      owner  => $instance,
      group  => $instance
    }
  )

  ensure_resource('file',
    "${instance_path}/releases/0/solr/${config_dir}",
    {
      ensure => 'link',
      target => $default_config
    }
  )

  # link to version 0 if there isn't a real version linked yet
  ensure_resource('file',
    "${instance_path}/current",
    {
      ensure  => 'link',
      target  => "${instance_path}/releases/0",
      replace => false,
    }
  )

  file { $real_core_path:
    ensure => 'directory',
    mode   => '2775',
    owner  => $solr_user,
    group  => $solr_group,
  }

  file { "${real_core_path}/conf":
    ensure => 'link',
    target => "${instance_path}/current/solr/${config_dir}",
  }

  file { $solr_core_path:
    ensure => 'link',
    target => $real_core_path
  }

  exec { "initialize solr core ${title}":
    unless  => "/usr/bin/wget -O - --quiet http://${host}:${port}/solr/${title}/admin/ping > /dev/null",
    command => "/usr/bin/wget -O - --quiet \"http://${host}:${port}/solr/admin/cores?action=CREATE&name=${title}&instanceDir=${solr_core_path}&config=solrconfig.xml&dataDir=data\" > /dev/null",
  }

}
