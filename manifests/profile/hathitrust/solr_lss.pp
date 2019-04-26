# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::solr_lss
#
# Provisions a single instance of solr for HathiTrust large scale search
#
# @param base   The directory under which all solr files will be deployed
# @param home   The value to use for HOME; solr cores go under here
# @param logs   The directory to use LOGS_DIR; where all the logging goes
# @param port   The port solr should listen on
# @param heap   How much memory to allocate for the Solr heap.
# @param timezone    The timezone to use for logs, etc. Should normally be set via Hiera.
# @param cores  A map of core names to The full paths on disk for the solr cores to load in this instance of solr
#
# @example
#   class { 'nebula::profile::hathitrust::solr_lss':
#     timezone   => 'America/New_York'
#     cores => {
#                      'core1' => '/path/to/core_1',
#                      'core2' => '/path/to/core_2'
#                   }
#   }
class nebula::profile::hathitrust::solr_lss (
  String $base = '/var/lib/solr',
  String $home = "${base}/home",
  String $logs = "${base}/logs",
  String $heap = '32G',
  Hash[String,String] $cores = {},
  Integer $port = 8983,
  String $timezone
) {

  ensure_packages(['openjdk-8-jre-headless'])
  $java_home = '/usr/lib/jvm/java-8-openjdk-amd64/jre'

  nebula::usergroup { 'solr': }

  $log4j_props = "${base}/log4j.properties"

  file {
    default:
      owner => 'solr',
      group => 'solr';
    [$base, $home, $logs]:
      ensure => 'directory',
      mode => '0750';
    $log4j_props:
      content => template('nebula/profile/hathitrust/solr_lss/log4j.properties.erb');
    "${base}/solr.in.sh":
      content => template('nebula/profile/hathitrust/solr_lss/solr.in.sh.erb');
    "${home}/solr.xml":
      content =>  template('nebula/profile/hathitrust/solr_lss/solr.xml.erb')
  }

  $cores.each |$core,$path| {
    file { "${home}/${core}":
      ensure => 'link',
      target => $path
    }
  }

}
