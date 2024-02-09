# nebula::profile::hathitrust::solr::catalog
#
# HathiTrust solr catalog profile
#
# @example
#   include nebula::profile::hathitrust::solr6::catalog
class nebula::profile::hathitrust::solr6::catalog (
  String $port = '9033',
  String $solr_home = '/var/lib/solr',
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

  # magic symlinks?

  # more magic symlinks?

  # catalog release script

}
