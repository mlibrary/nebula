# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base
#
# Disable mcollective on all machines and hpwdt on HP machines.
#
# Fully manage debian >= 9 machines.
#
# @param contact_email Contact email for MOTD
#   the file's contents directly)
# @param sysadmin_dept Current name of our department
# @param timezone Timezone
#
# @example
#   include nebula::profile::base
class nebula::profile::base (
  String  $contact_email,
  String  $sysadmin_dept,
  String  $timezone,
) {
  service { 'puppet':
    ensure => 'running',
    enable => true,
  }

  unless $facts['is_virtual'] {
    package { 'vlan': }
  }

  ensure_packages([
    'dbus', # ??
    'zstd', # prevent warnings about fallback on `apt dist-upgrade`
  ])

  file { '/etc/localtime':
    ensure => 'link',
    target => "/usr/share/zoneinfo/${timezone}",
  }

  file { '/etc/timezone':
    content => "${timezone}\n",
  }

  file { '/etc/hostname':
    content => "${::networking['fqdn']}\n",
    notify  => Exec["/bin/hostname ${::networking['fqdn']}"],
  }

  exec { "/bin/hostname ${::networking['fqdn']}":
    refreshonly => true,
  }

  class { 'nebula::profile::base::motd':
    contact_email => $contact_email,
    sysadmin_dept => $sysadmin_dept,
  }

  if $facts['dmi'] and ($facts['dmi']['manufacturer'] == 'HP' or $facts['dmi']['manufacturer'] == 'HPE') {
    include nebula::profile::base::hp
  }
}
