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

  include apache::mod::xsendfile

  include nebula::profile::prometheus::exporter::mysql

  include nebula::profile::apache::auth_openidc
}
