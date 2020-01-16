# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::solr
#
# Install Solr with base configuration.
# 
# Note: The variables set are also used by the erb files. 
class nebula::profile::solr (
  String $base = '/var/lib/solr',
  String $home = "${base}/home",
  String $logs = "${base}/logs",
  String $log4j_properties = "${base}/log4j.properties",
  String $solr_in_sh = "${base}/solr.in.sh",
  String $solr_xml = "${home}/solr.xml",
  String $heap = '1G',
  Integer $port = 8983
) {

  ensure_packages(['openjdk-8-jre-headless','solr','lsof'])

  # Note: Along with variables above these are used in erb files also.
  $java_home = '/usr/lib/jvm/java-8-openjdk-amd64/jre'
  $solr_bin = '/opt/solr/bin/solr'

  nebula::usergroup { 'solr': }

  file {
    default:
      owner => 'solr',
      group => 'solr',
    ;
    [$base, $home, $logs]:
      ensure => 'directory',
      mode   => '0750',
    ;
    $log4j_properties:
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/solr/log4j.properties.erb'),
    ;
    $solr_in_sh:
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/solr/solr.in.sh.erb'),
    ;
    $solr_xml:
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/solr/solr.xml.erb'),
    ;
  }

  file { '/etc/systemd/system/solr.service':
    owner   => 'root',
    group   => 'root',
    content => template('nebula/profile/solr/solr.service.erb'),
  }

  service { 'solr':
    ensure   => 'running',
    enable   => true,
    provider => 'systemd',
    require  => [
      File['/etc/systemd/system/solr.service']
    ]
  }

}
