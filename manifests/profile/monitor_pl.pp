# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

#
# @param directory The directory to deploy the monitor script & config to
# @param nfs_mounts NFS mounts to check (via ls)
# @param mysql The mysql host & credentials to attempt to connect as
# @param shibboleth Whether to check for shibd process
#
# @example
# class { 'nebula::profile::monitor_pl':
#   directory  => '/usr/lib/cgi-bin/monitor',
#   nfs_mounts => ['/www']
#   solr_cores => ['http://solr-host:8080/solr/core1']
#   mysql      => {
#     host     => 'mysql-whatever',
#     user     => 'someuser',
#     password => 'somepassword',
#     database => 'mydatabase'
#   },
#   shibboleth => true
# }
class nebula::profile::monitor_pl (
  String  $directory,
  Array[String] $nfs_mounts = [],
  Array[String] $solr_cores = [],
  Optional[Hash] $mysql = undef,
  Boolean $shibboleth = false,
) {

  $http_files = lookup('nebula::http_files')

  file { $directory:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   =>  '0755'
  }

  file { "${directory}/monitor.pl":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/monitor.pl"
  }

  $monitor_file = "${directory}/monitor_config.yaml"

  concat_file {  $monitor_file:
    tag    => 'monitor_config',
    owner  => 'root',
    group  => 'root',
    format => 'yaml',
    mode   => '0644',
  }

  concat_fragment {
    default:
      tag  => 'monitor_config';

    'monitor nfs mounts':
      content => { 'nfs' => $nfs_mounts }.to_yaml();
    'monitor solr cores':
      content => { 'solr' => $solr_cores }.to_yaml();
    'monitor mysql':
      content => { 'mysql' => $mysql }.to_yaml();
    'monitor shibboleth':
      content => { 'shibd' => $shibboleth }.to_yaml();

  }

}
