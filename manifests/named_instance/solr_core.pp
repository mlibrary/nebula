
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# A solr core for a named instance
#
# @example
define nebula::named_instance::solr_core (
  String $instance_path,
  String $instance,
  Integer $index,
  String $solr_home = lookup('nebula::named_instance::solr_core::solr_home'),
  String $config_dir = 'conf',
  String $host,
  Integer $port,
  String $default_config = lookup('nebula::named_instance::solr_core::default_config'),
  String $solr_user = 'solr',
  String $solr_group = 'solr',
) {
  $core_path = "${solr_home}/${title}"

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

  file { $core_path:
    ensure => 'directory',
    mode   => '2775',
    owner  => 'solr',
    group  => 'solr',
  }

  file { "${core_path}/conf":
    ensure => 'link',
    target => "${instance_path}/current/solr/${config_dir}",
  }

  exec { "initialize solr core ${title}":
    unless  => "/usr/bin/wget -O - --quiet http://${host}:${port}/solr/${title}/admin/ping > /dev/null",
    command => "/usr/bin/wget -O - --quiet \"http://${host}:${port}/solr/admin/cores?action=CREATE&name=${title}&instanceDir=${core_path}&config=solrconfig.xml&dataDir=data\" > /dev/null",
  }

}
