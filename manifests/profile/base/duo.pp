# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::duo
#
# A description of what this class does
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
      path  => "/etc/pam.d/${pamfile}",
      line  => 'auth required pam_duo.so',
      after => '^@include common-auth',
    }
  }

  file { '/etc/security/pam_duo.conf':
    content => template('nebula/profile/base/pam_duo.conf.erb'),
    mode    => '0600',
    require => Package['libpam-duo'],
  }
}
