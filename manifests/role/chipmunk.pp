class nebula::role::chipmunk {
  include nebula::role::app_host::prod
  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl
}
