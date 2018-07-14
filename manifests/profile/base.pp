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
    enable => true,
  }

  if $facts['os']['release']['major'] == '9' {
    package { 'dselect': }
    package { 'ifenslave': }
    package { 'linux-image-amd64': }
    package { 'vlan': }
    package { 'dbus': }
    package { 'dkms': }

    file { '/etc/localtime':
      ensure => 'link',
      target => "/usr/share/zoneinfo/${timezone}",
    }

    file { '/etc/timezone':
      content => "${timezone}\n",
    }

    file { '/etc/hostname':
      content => "${::fqdn}\n",
      notify  => Exec["/bin/hostname ${::fqdn}"],
    }

    exec { "/bin/hostname ${::fqdn}":
      refreshonly => true,
    }

    include nebula::profile::afs
    include nebula::profile::base::firewall::ipv4

    file { '/etc/motd':
      content => template('nebula/profile/base/motd.erb'),
    }

  }

  include nebula::profile::base::stop_mcollective
  include nebula::profile::base::blacklist_hpwdt
}
