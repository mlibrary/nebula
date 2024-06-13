# nebula::profile::hathitrust::solr6::classic
#
# Profile for the classic HathiTrust solr lss/catalog servers
#
# @example
#   include nebula::profile::hathitrust::solr6::classic
class nebula::profile::hathitrust::solr6::classic (
){
  nebula::log { 'lss_solr':
    files => ["/var/lib/solr-current-lss/logs/solr.log"],
  }
  nebula::log { 'catalog_solr':
    files => ["/var/lib/solr-current-catalog/logs/solr.log"],
  }
}
