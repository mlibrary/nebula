# nebula::profile::hathitrust::solr6::catalog
#
# HathiTrust solr catalog profile
#
# @example
#   include nebula::profile::hathitrust::solr6::catalog
class nebula::profile::hathitrust::solr6::catalog (
  String $port = '9033',
  String $solr_home = '/var/lib/solr',
  String $snapshot_name = 'htsolr-catalog',
  Boolean $is_primary_site = lookup('nebula::profile::hathitrust::solr6::is_primary_site', default_value => false),
  String $release_flag_prefix = lookup('nebula::profile::hathitrust::solr6::release_flag_prefix', default_value => ''),
  String $mirror_site_ip = lookup('nebula::profile::hathitrust::solr6::mirror_site_ip'),
  String $mail_recipient = lookup('nebula::profile::hathitrust::solr6::mail_recipient'),
  String $loki_endpoint_url = lookup('nebula::profile::hathitrust::loki_endpoint_url'),
){
  class { 'nebula::profile::hathitrust::solr6':
    port => $port,
    solr_home => $solr_home,
  }

  # solr nfs mounts
  nebula::nfs_mount { "/htsolr/catalog":
    tag             => "smartconnect",
    private_network => true,
    monitored       => true,
    before          => Service["solr"],
    remote_target   => "nas-${::datacenter}.sc:/ifs/htsolr/catalog";
  }

  # link to core in solr home
  file { "${solr_home}/catalog":
    ensure => "link",
    target => "/htsolr/serve/catalog",
    notify => Service["solr"],
  }

  # catalog release script
  $solr_name = "catalog"
  $solr_stop_flag = "STOPCATALOGRELEASE"
  $solr_cores = ["catalog"]
  $core_data_dir_template = 'data'
  $core_link_prefix = ""
  $is_catalog = true
  $is_primary_node = true # catalog solr is only one node per site
  file { "/usr/local/bin/index-release":
    owner   => "root",
    mode    => "755",
    content => template("nebula/profile/hathitrust/solr6/index-release.sh.erb"),
  }
  if ($is_primary_site) {
    $cron_h = 6
    $cron_m = 30
  } else {
    $cron_h = 6
    $cron_m = 25
  }
  cron { "catalog solr index release":
    hour    => $cron_h,
    minute  => $cron_m,
    command => "/usr/local/bin/index-release > /tmp/index-release.log 2>&1 || /usr/bin/mail -s '${facts['networking']['hostname']} catalog index release problem' ${mail_recipient} < /tmp/index-release.log",
  }

  class { 'nebula::profile::loki':
    log_files => {
      "catalog_solr" => ["/var/lib/solr/logs/solr.log"],
    },
    loki_endpoint_url => $loki_endpoint_url,
  }

}
