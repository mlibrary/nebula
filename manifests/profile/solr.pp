# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::solr
#
# Install Solr with base configuration.
# 
class nebula::profile::solr (
  String $base = '/var/lib/solr',
  String $home = "${base}/home",
  String $logs = "${base}/logs",
  String $solr_bin = '/opt/solr/bin/solr',
  String $heap = '1G',
  Integer $port = 8983
) {

  ensure_packages(['openjdk-8-jre-headless','solr','lsof'])
  $java_home = '/usr/lib/jvm/java-8-openjdk-amd64/jre'

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
    "${base}/log4j.properties":
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/solr/log4j.properties.erb'),
    ;
    "${base}/solr.in.sh":
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/solr/solr.in.sh.erb'),
    ;
    "${home}/solr.xml":
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/solr/solr.xml.erb'),
    ;
    "${solr_bin}":
      ensure  => 'file',
      mode    => '0755',
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
