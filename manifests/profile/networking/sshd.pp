# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::sshd
#
# Manage SSH
#
# @param whitelist A list of IPs to whitelist for pubkey auth
# @param gssapi_auth Whether to enable GSSAPI auth for whitelisted IPs
#
# @example
#   include nebula::profile::networking::sshd
class nebula::profile::networking::sshd (
  Array[String] $whitelist,
  String $addon_directives = '',
  Integer $port = 22,
) {

  # This will do nothing if the keytab doesn't exist
  include nebula::profile::networking::keytab
  $gssapi_auth = defined(File['/etc/krb5.keytab'])

  service { 'sshd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/ssh/sshd_config':
    content => template('nebula/profile/networking/sshd_config.erb'),
    notify  => Service['sshd'],
  }

  file { '/etc/ssh/ssh_config':
    content => template('nebula/profile/networking/ssh_config.erb'),
  }

  # The PAM defaults for sshd have been unchanged between jessie and buster...
  # If we need to update them, we can add some file selection here.
  file { '/etc/pam.d/sshd-defaults':
    source => 'puppet:///modules/nebula/pam.d/sshd-defaults',
  }

  concat_file { '/etc/pam.d/sshd': }

  concat_fragment { '/etc/pam.d/sshd: base':
    target  => '/etc/pam.d/sshd',
    order   => '01',
    content => @("EOT")
      # Managed by puppet (manifests/profile/networking/sshd)

      @include sshd-defaults
      | EOT
  }
}
