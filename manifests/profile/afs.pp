# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::afs
#
# Manage OpenAFS and kerberos.
#
# @example
#   include nebula::profile::afs
class nebula::profile::afs (
  String  $allow_auto_reboot_until,
  Integer $cache_size,
  String  $cell,
  String  $realm,
) {
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
    command => '/usr/bin/apt-get -y install linux-image-amd64',
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
    value => $cache_size,
  }
}
