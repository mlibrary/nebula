# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base
#
# Disable mcollective on all machines and hpwdt on HP machines.
#
# @param bridge_network Whether to add bridge network interfaces
# @param keytab Path to a source file to use as a kerberos keytab (leave
#   blank or point to a nonexistent file to disable the keytab)
#
# @example
#   include nebula::profile::base
class nebula::profile::base (
  String  $contact_email,
  String  $default_keytab,
  String  $keytab,
  String  $keytab_source,
  String  $sysadmin_dept,
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

    include nebula::profile::afs
    include nebula::profile::base::apt
    include nebula::profile::base::authorized_keys
    include nebula::profile::base::duo
    include nebula::profile::base::exim4
    include nebula::profile::base::firewall::ipv4
    include nebula::profile::base::grub
    include nebula::profile::base::ntp
    include nebula::profile::base::users
    include nebula::profile::base::vim

    class { 'nebula::profile::base::sysctl':
      bridge => $bridge_network,
    }

    $keytab_content = file($keytab, $default_keytab)

    if $keytab_content == '' {
      include nebula::profile::base::sshd
    } else {
      class { 'nebula::profile::base::sshd':
        gssapi_auth => true,
      }

      if $keytab_source == '' {
        file { '/etc/krb5.keytab':
          content => $keytab_content,
          mode    => '0600',
        }
      } else {
        file { '/etc/krb5.keytab':
          source => $keytab_source,
          mode   => '0600',
        }
      }
    }

    file { '/etc/motd':
      content => template('nebula/profile/base/motd.erb'),
    }
  }

  include nebula::profile::base::stop_mcollective
  include nebula::profile::base::blacklist_hpwdt
}
