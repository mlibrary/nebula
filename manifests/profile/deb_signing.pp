# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::deb_signing
#
# Dependencies and scripts for signing a Debian repository
#
# @param sign_key The key to use when signing the repository
# @param sign_script The script to install as /var/local/update_debs
#
# @example
#   class { 'nebula::profile::deb_signing':
#     sign_key    => puppet:///somewhere/my_key.key
#     sign_script => puppet:///somewhere/signit.sh
#   }

#   include nebula::profile::deb_signing

class nebula::profile::deb_signing (
  String $sign_key,
  String $sign_script
) {

  package { ['gnupg', 'dpkg-dev', 'pinentry-curses', 'apt-utils']: }

  file { '/var/local/deb-signing.key':
    ensure => 'file',
    source => $sign_key,
    owner  => 'root',
    group  => 'dlps',
    mode   => '0640'
  }

  file { '/var/local/update_debs':
    ensure => 'file',
    source => $sign_script,
    owner  => 'root',
    group  => 'dlps',
    mode   => '0750'
  }

}
