# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::solr

class nebula::profile::fulcrum::solr (
  String $base = '/var/lib/solr',
  String $home = "${base}/home",
  String $logs = "${base}/logs",
  String $log4j_properties = "${base}/log4j.properties",
  String $solr_in_sh = "${base}/solr.in.sh",
  String $solr_xml = "${base}/solr.xml",
  String $jdk_version = '8',
  String $solr_home = '/var/lib/solr',
  String $java_home = "/usr/lib/jvm/temurin-${jdk_version}-jre-${$facts['os']['architecture']}",
  String $heap = '16G',
  String $timezone = 'America/Detroit',
  String $solr_bin = '/opt/solr/bin/solr',
) {
  ensure_packages([
    "temurin-${jdk_version}-jre",
    'solr',
    'lsof',
  ])

  nebula::usergroup { 'solr': }

  file {
    default:
      owner => 'solr',
      group => 'fulcrum',
    ;
    [$base, $home, $logs]:
      ensure => 'directory',
      mode   => '0775',
    ;
    $log4j_properties:
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/fulcrum/solr/log4j.properties.erb'),
    ;
    $solr_in_sh:
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/fulcrum/solr/solr.in.sh.erb'),
    ;
    $solr_xml:
      ensure  => 'file',
      mode    => '0644',
      content => template('nebula/profile/fulcrum/solr/solr.xml.erb'),
    ;
  }
  file { '/etc/systemd/system/solr.service':
    owner   => 'root',
    group   => 'root',
    content => template('nebula/profile/fulcrum/solr/solr.service.erb'),
  }
  service { 'solr':
    ensure  => 'running',
    enable  => true,
    require => [Package['solr'], File['/etc/systemd/system/solr.service']],
  }

  class { 'nebula::profile::openjdk_java':
    jdk_packages     => ["temurin-${jdk_version}-jre"],
    default_jdk      => "temurin-${jdk_version}-jre",
    base_alternative => $java_home,
    java_alternative => "temurin-${jdk_version}-jre-amd64",
  }

  file { '/etc/environment':
      content => inline_template("JAVA_HOME=${java_home}")
      ;
  }

  file {
    ['/var/lib/solr/data/cores']:
      ensure => 'directory',
      owner  => 'solr',
      group  => 'solr',
    ;
  }
}
