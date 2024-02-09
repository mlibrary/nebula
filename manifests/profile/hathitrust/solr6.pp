# nebula::profile::hathitrust::solr6
#
# Install common dependencies for solr6 hosts
# everything but the index and release process
#
# @example
#   include nebula::profile::hathitrust::solr6
class nebula::profile::hathitrust::solr6 (
  String $jdk_version = '8',
  String $solr_home = '/var/lib/solr',
  String $java_home = "/usr/lib/jvm/java-${jdk_version}-openjdk-amd64",
  String $heap = '16G',
  String $timezone = 'America/Detroit',
  String $solr_bin = '/opt/solr/bin/solr',
  String $port,
){
  include nebula::profile::hathitrust::networking
  include nebula::profile::hathitrust::hosts

  package { "openjdk-${jdk_version}-jre-headless": }
  package { "solr": }

  include nebula::profile::dns::smartconnect;

  include nebula::profile::users
  realize User["solr"]

  # parent dir structure for solr mounts, not all used by every use case
  file {
    default:
      ensure => "directory",
      owner  => "root",
      mode   => "755",
    ;
    "/htsolr":;
    "/htsolr/lss":;
    "/htsolr/lss/cores":;
    "/htsolr/serve":;
  }
  nebula::nfs_mount {
    default:
      tag             => "smartconnect",
      private_network => true,
      monitored       => true,
      before          => Service["solr"],
    ;
    "/htapps":            remote_target => "nas-${::datacenter}.sc:/ifs/htapps";
  }

  # solr config files
  file {
    default:
      ensure => "directory",
      owner  => "solr",
      group  => "htprod",
      mode   => "2775",
      before => Service["solr"],
    ;
    $solr_home:;
    "${solr_home}/logs":;
  }
  file {
    default:
      owner  => "root",
      mode   => "644",
      notify => Service["solr"],
    ;
    "${solr_home}/log4j.properties":    content => template("nebula/profile/hathitrust/solr6/log4j.properties.erb");
    "${solr_home}/solr.in.sh":          content => template("nebula/profile/hathitrust/solr6/solr.in.sh.erb");
    "${solr_home}/solr.xml":            content => template("nebula/profile/hathitrust/solr6/solr.xml.erb");
    "/etc/systemd/system/solr.service": content => template("nebula/profile/hathitrust/solr6/solr.service.erb"),
  }
  service { "solr":
    ensure  => "running",
    enable  => true,
    require => [Package["solr"], File["/etc/systemd/system/solr.service"]],
  }

  # allow access to solr port servers, staff
  nebula::exposed_port {
    default: port => $port;
    "200 Solr - Private": block => "hathitrust::networks::private_all";
    "200 Solr - Staff":   block => "hathitrust::networks::staff";
  }
}
