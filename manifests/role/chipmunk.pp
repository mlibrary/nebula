class nebula::role::chipmunk {
  include nebula::role::app_host::standalone

  # Make it possible for the catalog to apply on jessie while we are upgrading.
  if $facts['os']['family'] == 'Debian' and $::lsbdistcodename != 'jessie' {
    include nebula::profile::hathitrust::dependencies
    include nebula::profile::hathitrust::perl

    # Ensure that group-write umask is set for uploaders.
    # This does not take effect when the repository storage is mounted via
    # CIFS, but does when on local disk or NFS.
    file { '/etc/pam.d/sshd':
      require => File["/etc/pam.d/sshd-${::lsbdistcodename}"],
      notify  => Service['sshd'],
      content => @("EOT")
        # Managed by puppet (manifests/role/chipmunk)

        @include sshd-${::lsbdistcodename}

        # Set the umask for uploads
        session    optional   pam_umask.so umask=0002
      | EOT
    }

    file { "/etc/pam.d/sshd-${::lsbdistcodename}":
      source => "puppet:///modules/nebula/pam.d/sshd-${::lsbdistcodename}",
    }
  }

  # should be conditionally included from named_instances::apache when the
  # vhost config is deployed on the web node
  include apache::mod::xsendfile
}
