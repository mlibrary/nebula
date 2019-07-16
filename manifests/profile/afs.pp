# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::afs
#
# Manage OpenAFS and kerberos.
#
# If you're setting up a new machine, you'll need to reboot it after
# puppet's run all this. If you'd rather take a hands-off approach, you
# can set $allow_auto_reboot_until to such as tomorrow's date, and
# puppet will reboot for you.
#
# It's best practice to remove that setting when done, but this way, if
# you forget, you don't have to worry about the machine getting caught
# in a reboot loop for some reason in the future.
#
# Also, if you ever see any machines with this set to a date in the
# past, feel free to delete the setting.
#
# @param allow_auto_reboot_until A YYYY-mm-dd date at which puppet will
#   no longer automatically reboot the machine
# @param cache_size debconf openafs-client/cachesize
# @param cell debconf openafs-client/thiscell
# @param realm debconf krb5-config/default_realm
#
# @example
#   include nebula::profile::afs
class nebula::profile::afs (
  String  $allow_auto_reboot_until,
  Integer $cache_size,
  String  $cell,
  String  $realm,
) {

  include nebula::profile::networking::keytab

  if nebula::date_is_in_the_future($allow_auto_reboot_until) {
    reboot { 'afs':
      apply     => 'finished',
      subscribe => Exec['reinstall kernel to enable afs'],
    }
  }

  package { 'krb5-user': }
  package { 'libpam-afs-session': }
  package { 'libpam-krb5': }
  package { 'openafs-client': }
  package { 'openafs-krb5': }
  package { 'openafs-modules-dkms': }

  exec { 'reinstall kernel to enable afs':
    command => '/usr/bin/apt-get -y install --reinstall linux-headers-amd64',
    creates => "/lib/modules/${::kernelrelease}/updates/dkms/openafs.ko",
    timeout => 600,
    require => Package['openafs-modules-dkms'],
  }

  debconf { 'krb5-config/default_realm':
    type  => 'string',
    value => $realm,
  }

  debconf { 'openafs-client/thiscell':
    type  => 'string',
    value => $cell,
  }

  debconf { 'openafs-client/cachesize':
    type  => 'string',
    value => sprintf('%d', $cache_size),
  }

  file { '/usr/local/skel/sys.login':
    source => 'puppet:///modules/nebula/skel.txt',
  }

  file { '/usr/local/skel/sys.profile':
    source  => 'puppet:///modules/nebula/skel.txt',
  }

  file { '/usr/local/skel':
    ensure => 'directory',
    mode   => '0755',
  }
}
