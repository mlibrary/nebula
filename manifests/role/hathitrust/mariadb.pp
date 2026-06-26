class nebula::role::hathitrust::mariadb {
  include nebula::role::minimum
  include nebula::profile::hathitrust::hosts
  include nebula::profile::mariadb::server
}
