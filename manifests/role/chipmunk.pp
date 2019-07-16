class nebula::role::chipmunk {
  include nebula::role::app_host::standalone

  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl

  # should be conditionally included from named_instances::apache when the
  # vhost config is deployed on the web node
  include apache::mod::xsendfile
}
