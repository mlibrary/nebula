# nebula::role::hathitrust::solr::lss
#
# HathiTrust solr lss server
#
# @example
#   include nebula::role::hathitrust::solr::lss
class nebula::role::hathitrust::solr::lss {
  class { 'nebula::role::hathitrust':
    afs => false,
  }

  include nebula::profile::hathitrust::solr6::lss
}
