# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::duo
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
#   include nebula::profile::base::duo
class nebula::profile::base::duo (
  String $ikey,
  String $skey,
  String $host,
  String $pushinfo,
  String $failmode,
) {
  package { 'sudo': }
  package { 'libpam-duo': }

  ['sshd', 'sudo'].each |$pamfile| {
    file_line { "/etc/pam.d/${pamfile}: pam_duo":
      path    => "/etc/pam.d/${pamfile}",
      line    => 'auth required pam_duo.so',
      after   => '^@include common-auth',
      require => Package['sudo', 'libpam-duo'],
    }
  }

  file { '/etc/security/pam_duo.conf':
    content => template('nebula/profile/base/pam_duo.conf.erb'),
    mode    => '0600',
    require => Package['libpam-duo'],
  }
}
