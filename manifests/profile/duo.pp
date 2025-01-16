# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::duo
#
# Manage Duo.
#
# @param ikey Duo integration key
# @param skey Duo secret key
# @param host Duo API host
# @param pushinfo Send command for Duo Push authentication
# @param failmode Fail mode
#
# @example
#   include nebula::profile::duo
class nebula::profile::duo (
  String $ikey,
  String $skey,
  String $host,
  String $pushinfo,
  String $failmode,
) {
  ensure_packages([
    'sudo',
    'libpam-duo'
  ])

  # Replace default /etc/pam.d/sudo
  # This is only here to eliminate previous customizations
  # Remove after January 2025
  file { '/etc/pam.d/sudo':
    source  => "puppet:///modules/nebula/default/${facts['os']['distro']['codename']}/etc/pam.d/sudo",
  }

  concat_fragment { '/etc/pam.d/sshd: pam_duo':
    target  => '/etc/pam.d/sshd',
    content => @("EOT")

      # Require Duo 2FA for password logins; public-key bypasses PAM
      auth required pam_duo.so
      | EOT
  }

  file { '/etc/security/pam_duo.conf':
    content => template('nebula/profile/duo/pam_duo.conf.erb'),
    mode    => '0600',
    require => Package['libpam-duo'],
  }
}
