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
  apt::source { 'duo':
    source_format => 'sources',
    location      => ["https://pkg.duosecurity.com/${$facts['os']['name']}"],
    release       => $facts['os']['distro']['codename'],
    repos         => ['main'],
    keyring       => '/etc/apt/keyrings/duo.asc',
  }

  apt::keyring { 'duo.asc':
    source => 'puppet:///modules/nebula/apt/keyrings/duo.asc',
  }

  package { default:
    ensure  => purged,
    require => Package['duo-unix'],
    ;
    'libpam-duo': ;
    'libduo3': ;
    'libduo3t64': ;
  }

  package { 'duo-unix':
    require => Apt::Source['duo'],
  }

  concat_fragment { '/etc/pam.d/sshd: pam_duo':
    target  => '/etc/pam.d/sshd',
    content => @("EOT")

      # Require Duo 2FA for password logins; public-key bypasses PAM
      auth required /lib64/security/pam_duo.so
      | EOT
  }

  file { '/etc/duo/pam_duo.conf':
    content => template('nebula/profile/duo/pam_duo.conf.erb'),
    mode    => '0600',
    require => Package['duo-unix'],
  }
}
