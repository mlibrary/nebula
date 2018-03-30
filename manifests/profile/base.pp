# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base
#
# Disable mcollective on all machines and hpwdt on HP machines.
#
# @param bridge_network Whether to add bridge network interfaces
# @param keytab Path to a source file to use as a kerberos keytab (leave
#   blank or point to a nonexistant file to disable the keytab)
#
# @example
#   include nebula::profile::base
class nebula::profile::base (
  String  $keytab,
  String  $timezone,
  Boolean $bridge_network = false,
) {
  if $facts['os']['release']['major'] == '9' {
    # Ensure that apt knows to never ever install recommended packages
    # before it installs any packages.
    File['/etc/apt/apt.conf.d/99no-recommends'] -> Package<| |>
    file { '/etc/apt/apt.conf.d/99no-recommends':
      content => template('nebula/profile/base/apt_no_recommends.erb'),
    }

    package { 'dselect': }
    package { 'ifenslave': }
    package { 'linux-image-amd64': }
    package { 'vlan': }
    package { 'tiger': }
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

    include nebula::profile::base::authorized_keys
    include nebula::profile::base::firewall::ipv4

    class { 'nebula::profile::base::sysctl':
      bridge => $bridge_network,
    }

    if nebula::file_exists($keytab) {
      class { 'nebula::profile::base::sshd':
        gssapi_auth => true,
      }

      file { '/etc/krb5.keytab':
        source => "file://${keytab}",
        mode   => '0600',
      }
    } else {
      include nebula::profile::base::sshd
    }
  }

  include nebula::profile::base::stop_mcollective
  include nebula::profile::base::blacklist_hpwdt
}
