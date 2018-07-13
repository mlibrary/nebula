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
# @param default_keytab Path to fallback keytab file
# @param keytab Path to desired keytab file
# @param keytab_source File source value for keytab (to avoid sending
#   the file's contents directly)
# @param sysadmin_dept Current name of our department
# @param timezone Timezone
# @param bridge_network Whether to add bridge network interfaces
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
  service { 'puppet':
    enable => true,
  }

  if $facts['os']['release']['major'] == '9' {
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
    include nebula::profile::base::authorized_keys
    include nebula::profile::base::firewall::ipv4
    include nebula::profile::base::users

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

    # Fix AEIM-1064. This prevents `systemctl is-active` from returning
    # a false negative when either of these is unmasked.
    #
    # To tell whether it's safe to remove this, try running the
    # following:
    #
    #     systemctl unmask procps
    #     systemctl unmask sshd
    #     systemctl is-active procps \
    #       && systemctl is-active sshd \
    #       && echo "AEIM-1064 no longer applies; get rid of the fix" \
    #       || echo "AEIM-1064 still applies; leave the ugly hack alone"
    exec { default:
        subscribe   => Service['procps', 'sshd'],
        refreshonly => true,
      ;
      '/bin/systemctl status procps':;
      '/bin/systemctl status sshd':;
    }
  }

  include nebula::profile::base::stop_mcollective
  include nebula::profile::base::blacklist_hpwdt
}
