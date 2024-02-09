# nebula::profile::hathitrust::solr::lss
#
# HathiTrust solr lss profile
#
# @example
#   include nebula::profile::hathitrust::solr6::lss
class nebula::profile::hathitrust::solr6::lss (
  String $port = '8081',
  String $solr_home = '/var/lib/solr',
  String $snapshot_name = 'htsolr-lss',
  Boolean $is_primary_site = false,
  Boolean $is_primary_node = false,
  Array[String] $solr_cores,
  String $mirror_site_ip,
  String $mail_recipient,
){
  class { 'nebula::profile::hathitrust::solr6':
    port => $port,
    solr_home => $solr_home,
  }

  # solr nfs mounts
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

  # lss release script
  file { "/usr/local/bin/index-release-lss":
    owner   => "root",
    mode    => "755",
    content => template("nebula/profile/hathitrust/solr6/lss/index-release-lss.sh.erb"),
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
