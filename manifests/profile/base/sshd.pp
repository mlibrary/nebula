# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::sshd
#
# Manage SSH
#
# @param whitelist A list of IPs to whitelist for pubkey auth
# @param gssapi_auth Whether to enable GSSAPI auth for whitelisted IPs
#
# @example
#   include nebula::profile::base::sshd
class nebula::profile::base::sshd (
  Array[String] $whitelist,
  Boolean       $gssapi_auth = false,
) {
  service { 'sshd':
    ensure => 'running',
    enable => true,
  }

  file { '/etc/ssh/sshd_config':
    content => template('nebula/profile/base/sshd_config.erb'),
    notify  => Service['sshd'],
  }
}
