# nebula::profile::hathitrust::solr6::classic
#
# Profile for the classic HathiTrust solr lss/catalog servers
#
# @example
#   include nebula::profile::hathitrust::solr6::classic
class nebula::profile::hathitrust::solr6::classic (
  String $loki_endpoint_url = lookup('nebula::profile::hathitrust::loki_endpoint_url'),
  Boolean $catalog_solr = false,
){
  if($catalog_solr) {
    class { 'nebula::profile::loki':
      log_files => {
        "catalog_solr" => ["/var/lib/solr-current-catalog/logs/solr.log"],
        "lss_solr"     => ["/var/lib/solr-current-lss/logs/solr.log"],
      },
      loki_endpoint_url => $loki_endpoint_url,
    }
  } else {
    class { 'nebula::profile::loki':
      log_files => {
        "lss_solr" => ["/var/lib/solr-current-lss/logs/solr.log"],
      },
      loki_endpoint_url => $loki_endpoint_url,
    }
  }
}
