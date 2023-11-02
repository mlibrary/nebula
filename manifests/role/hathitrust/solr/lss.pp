# HathiTrust solr large scale search server
#
# @example
#   include nebula::role::hathitrust::solr::lss
class nebula::role::hathitrust::solr::lss {
  include nebula::role::minimum

  include nebula::profile::krb5
  include nebula::profile::duo
  include nebula::profile::exim4
  include nebula::profile::grub
  include nebula::profile::ntp
  include nebula::profile::users
  include nebula::profile::networking

  include nebula::profile::hathitrust::networking
  include nebula::profile::dns::smartconnect
  include nebula::profile::hathitrust::hosts

  include nebula::profile::elastic::metricbeat
  include nebula::profile::elastic::filebeat::prospectors::ulib

  include nebula::profile::hathitrust::lss
}
