# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::solr_lss
#
# Provisions a single instance of solr for HathiTrust large scale search
#
# @param solr_base The directory under which all solr files will be deployed
# @param solr_home The value to use for SOLR_HOME; solr cores go under here
# @param solr_logs The directory to use SOLR_LOGS_DIR; where all the logging goes
# @param solr_port The port solr should listen on
# @param solr_heap How much memory to allocate for the Solr heap.
# @param timezone  The timezone to use for logs, etc. Should normally be set via Hiera.
#
# @example
#   class { 'nebula::profile::hathitrust::solr_lss':
#     timezone => 'America/New_York'
#   }
class nebula::profile::hathitrust::solr_lss (
  String $solr_base = '/var/lib/solr',
  String $solr_home = "${solr_base}/home",
  String $solr_logs = "${solr_base}/logs",
  String $solr_heap = '32G',
  Integer $solr_port = 8983,
  String $timezone
) {

  ensure_packages(['openjdk-8-jre-headless'])
  $java_home = '/usr/lib/jvm/java-8-openjdk-amd64/jre'

  nebula::usergroup { 'solr': }

  $log4j_props = "${solr_base}/log4j.properties"

  file {
    default:
      owner => 'solr',
      group => 'solr';
    [$solr_base, $solr_home, $solr_logs]:
      ensure => 'directory',
      mode => '0750';
    $log4j_props:
      content => template('nebula/profile/hathitrust/solr_lss/log4j.properties.erb');
    "${solr_base}/solr.in.sh":
      content => template('nebula/profile/hathitrust/solr_lss/solr.in.sh.erb');
    "${solr_home}/solr.xml":
      content =>  template('nebula/profile/hathitrust/solr_lss/solr.xml.erb')
  }

}
