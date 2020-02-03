class nebula::role::chipmunk {
  include nebula::role::app_host::standalone

  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl

  # Ensure that users can upload files with group write so the ingest
  # process can move them afterward.
  #
  # This is not required when the repository storage is mounted via
  # CIFS, but it is when on local disk or NFS.
  include nebula::profile::networking::sshd_group_umask

  # should be conditionally included from named_instances::apache when the
  # vhost config is deployed on the web node
  include apache::mod::xsendfile
}
