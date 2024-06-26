# nebula::role::hathitrust::solr::catalog
#
# HathiTrust solr catalog server
#
# @example
#   include nebula::role::hathitrust::solr::catalog
class nebula::role::hathitrust::solr::catalog {
  class { 'nebula::role::hathitrust':
    afs => false,
  }

  include nebula::profile::hathitrust::solr6::catalog
}
