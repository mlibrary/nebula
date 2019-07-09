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

  if $facts['os']['family'] == 'Debian' and $facts['os']['family']['distro']['codename'] != 'jessie' {
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

    file { '/etc/motd':
      content => template('nebula/profile/base/motd.erb'),
    }

  }

  include nebula::profile::base::stop_mcollective


  if $facts['dmi'] and ($facts['dmi']['manufacturer'] == 'HP' or $facts['dmi']['manufacturer'] == 'HPE') {
    include nebula::profile::base::hp
  }

  include nebula::profile::base::i40e
}
