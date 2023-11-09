# HathiTrust solr large scale search server
#
# @example
#   include nebula::profile::hathitrust::lss
class nebula::profile::hathitrust::lss (
  String $jdk_version = '11',
  String $solr_home = '/var/lib/solr',
  String $java_home = "/usr/lib/jvm/java-${jdk_version}-openjdk-amd64",
  String $heap = '32G',
  String $timezone = 'America/Detroit',
  String $port = '8081',
  String $solr_bin = '/opt/solr/bin/solr',
  String $snapshot_name = 'htsolr-lss',
  Boolean $is_primary_site = false,
  Boolean $is_primary_node = false,
  Array[String] $solr_cores,
  String $mirror_site_ip,
  String $mail_recipient,
){
  package { "openjdk-${jdk_version}-jre-headless": }
  package { "solr": }

  include nebula::profile::dns::smartconnect;

  # mount solr index, htapps
  file {
    default:
      ensure => "directory",
      owner  => "root",
      mode   => "755",
    ;
    "/htsolr":;
    "/htsolr/serve":;
    "/htsolr/lss":;
    "/htsolr/lss/cores":;
  }
  $solr_cores.each |$core| {
    nebula::nfs_mount { "/htsolr/lss/cores/${core}":
      tag             => "smartconnect",
      private_network => true,
      monitored       => true,
      before          => Service["solr"],
      remote_target   => "nas-${::datacenter}.sc:/ifs/htsolr/lss/cores/${core}";
    }
  }
  nebula::nfs_mount {
    default:
      tag             => "smartconnect",
      private_network => true,
      monitored       => true,
      before          => Service["solr"],
    ;
    "/htsolr/lss/flags":  remote_target => "nas-${::datacenter}.sc:/ifs/htsolr/lss/flags";
    "/htsolr/lss/prep":   remote_target => "nas-${::datacenter}.sc:/ifs/htsolr/lss/prep";
    "/htsolr/lss/shared": remote_target => "nas-${::datacenter}.sc:/ifs/htsolr/lss/shared";
    "/htapps":            remote_target => "nas-${::datacenter}.sc:/ifs/htapps";
  }

  include nebula::profile::users
  realize User["solr"]

  # lss solr conf
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
    "${solr_home}/log4j.properties": content => template("nebula/profile/hathitrust/solr_lss/log4j.properties.erb");
    "${solr_home}/solr.in.sh":       content => template("nebula/profile/hathitrust/solr_lss/solr.in.sh.erb");
    "${solr_home}/solr.xml":         content => template("nebula/profile/hathitrust/solr_lss/solr.xml.erb");
  }
  # core configs require jars to be available in solr home as well as /htsolr/serve
  file { "${solr_home}/lib":
    ensure => "link",
    target => "/htsolr/serve/lss-shared/lib",
    before => Service["solr"],
  }
  # link to cores in solr home
  $solr_cores.each |$core| {
    file { "${solr_home}/${core}":
      ensure => "link",
      target => "/htsolr/serve/lss-${core}",
      notify => Service["solr"],
    }
  }

  # lss service
  file { "/etc/systemd/system/solr.service":
    content => template("nebula/profile/hathitrust/solr_lss/solr.service.erb"),
    notify  => Service["solr"],
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

  # lss release script
  file { "/usr/local/bin/index-release-lss":
    owner   => "root",
    mode    => "755",
    content => template("nebula/profile/hathitrust/solr_lss/index-release-lss.sh.erb"),
  }
  if ($is_primary_site) {
    cron { "lss solr index release":
      hour    => 6,
      minute  => 0,
      command => "/usr/local/bin/index-release-lss > /tmp/index-release-lss.log 2>&1 || /usr/bin/mail -s '${facts['networking']['hostname']} lss index release problem' ${mail_recipient} < /tmp/index-release-lss.log",
    }
  } else {
    cron { "lss solr index release":
      hour    => 5,
      minute  => 55,
      command => "/usr/local/bin/index-release-lss > /tmp/index-release-lss.log 2>&1 || /usr/bin/mail -s '${facts['networking']['hostname']} lss index release problem' ${mail_recipient} < /tmp/index-release-lss.log",
    }
  }
}
