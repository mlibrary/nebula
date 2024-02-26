# nebula::profile::hathitrust::solr6::lss
#
# HathiTrust solr lss profile
#
# @example
#   include nebula::profile::hathitrust::solr6::lss
class nebula::profile::hathitrust::solr6::lss (
  String $port = '8081',
  String $solr_home = '/var/lib/solr',
  String $snapshot_name = 'htsolr-lss',
  Boolean $is_primary_site = lookup('nebula::profile::hathitrust::solr6::is_primary_site', default_value => false),
  Boolean $is_primary_node = false,
  String $release_flag_prefix = lookup('nebula::profile::hathitrust::solr6::release_flag_prefix', default_value => ''),
  String $mirror_site_ip = lookup('nebula::profile::hathitrust::solr6::mirror_site_ip'),
  String $mail_recipient = lookup('nebula::profile::hathitrust::solr6::mail_recipient'),
  Array[String] $solr_cores,
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
  $solr_name = "lss"
  $solr_stop_flag = "STOPLSSRELEASE"
  $core_data_dir_template = 'core-${s}x/data'
  $core_link_prefix = "lss-"
  $is_lss = true
  file { "/usr/local/bin/index-release":
    owner   => "root",
    mode    => "755",
    content => template("nebula/profile/hathitrust/solr6/index-release.sh.erb"),
  }
  if ($is_primary_site) {
    $cron_h = 6
    $cron_m = 0
  } else {
    $cron_h = 5
    $cron_m = 55
  }
  cron { "lss solr index release":
    hour    => $cron_h,
    minute  => $cron_m,
    command => "/usr/local/bin/index-release > /tmp/index-release.log 2>&1 || /usr/bin/mail -s '${facts['networking']['hostname']} lss index release problem' ${mail_recipient} < /tmp/index-release.log",
  }
}
