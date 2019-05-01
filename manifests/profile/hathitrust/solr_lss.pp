# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::solr_lss
#
# Provisions a single instance of solr for HathiTrust large scale search.
# For each given "shard" (in HathiTrust solr parlance), this provisions the lib
# and conf directory for an "x" and "y" core and symlinks the data directory
# for the shard.
#
# @param timezone  The timezone to use for logs, etc. Should normally be set via Hiera.
# @param coredata  A map of core names to the full paths on disk for the data
#                  directory for those cores.
# @param base   The directory under which all solr files will be deployed
# @param home   The value to use for HOME; solr cores go under here
# @param logs   The directory to use LOGS_DIR; where all the logging goes
# @param port   The port solr should listen on
# @param heap   How much memory to allocate for the Solr heap.
#
# @example
#   class { 'nebula::profile::hathitrust::solr_lss':
#     timezone                 => 'America/New_York'
#     coredata                 => {
#                      'core1' => '/path/to/core_1/data',
#                      'core2' => '/path/to/core_2/data'
#                   }
#   }
class nebula::profile::hathitrust::solr_lss (
  String $timezone,
  Hash[String,String] $coredata = {},
  String $base = '/var/lib/solr',
  String $home = "${base}/home",
  String $logs = "${base}/logs",
  String $heap = '32G',
  Integer $port = 8983
) {

  ensure_packages(['openjdk-8-jre-headless','solr'])
  $java_home = '/usr/lib/jvm/java-8-openjdk-amd64/jre'

  nebula::usergroup { 'solr': }

  $log4j_props = "${base}/log4j.properties"
  $solr_in_sh = "${base}/solr.in.sh"
  $solr_bin = '/opt/solr/bin/solr'

  file {
    default:
      owner => 'solr',
      group => 'solr';
    [$base, $home, $logs]:
      ensure => 'directory',
      mode   => '0750';
    $log4j_props:
      content => template('nebula/profile/hathitrust/solr_lss/log4j.properties.erb');
    $solr_in_sh:
      content => template('nebula/profile/hathitrust/solr_lss/solr.in.sh.erb');
    "${home}/solr.xml":
      content =>  template('nebula/profile/hathitrust/solr_lss/solr.xml.erb')
  }

  file { '/etc/systemd/system/solr.service':
    owner   => 'root',
    group   => 'root',
    content => template('nebula/profile/hathitrust/solr_lss/solr.service.erb')
  }

  $coredata.each |$core,$path| {
    file { "${home}/${core}":
      ensure => 'directory',
      owner  => 'solr',
      group  => 'solr',
      mode   => '0750'
    }

    file { "${home}/${core}/data":
      ensure => 'link',
      target => $path
    }


    ['x','y'].each |$suffix| {
      $subcore_home = "${home}/${core}/${core}${suffix}"

      file {
        default:
          owner => 'solr',
          group => 'solr';

        $subcore_home:
          ensure => 'directory';

        "${subcore_home}/core.properties":
          content => template("nebula/profile/hathitrust/solr_lss/core_${suffix}.properties.erb");

        "${subcore_home}/lib":
          ensure  => 'directory',
          source  => 'puppet:///modules/nebula/solr_lss/lib',
          recurse => true;

        "${subcore_home}/conf":
          ensure  => 'directory',
          source  => 'puppet:///modules/nebula/solr_lss/conf',
          recurse => true;

        "${subcore_home}/conf/schema.xml":
          source => "puppet:///modules/nebula/solr_lss/conf/schema_${suffix}.xml"
      }
    }
  }

}
