# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::networking::sshd
#
# Manage SSH
#
# @param whitelist A list of IPs to whitelist for pubkey auth
# @param gssapi_auth Whether to enable GSSAPI auth for whitelisted IPs
#
# @example
#   include nebula::profile::networking::sshd
class nebula::profile::networking::sshd (
  Array[String] $whitelist,
  String $addon_directives = '',
  Integer $port = 22,
) {
  # This will do nothing if the keytab doesn't exist
  include nebula::profile::networking::keytab
  $gssapi_auth = defined(File['/etc/krb5.keytab'])

  service { 'sshd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/ssh/ssh_config.d/80-lit.conf':
    content => template('nebula/profile/networking/ssh_config.erb'),
  }

  # Reset sshd_config to original distro config. May be deleted once this has been applied to existing hosts.
  file { '/etc/ssh/sshd_config':
    source => "puppet:///modules/nebula/default/${facts['os']['distro']['codename']}/etc/ssh/sshd_config",
    notify => Service['sshd'],
  }

  file { '/etc/ssh/sshd_config.d/50-lit.conf':
    content => template('nebula/profile/networking/sshd_config.erb'),
    notify  => Service['sshd'],
  }

  # Reset ssh_config to original distro config. May be deleted once this has been applied to existing hosts.
  file { '/etc/ssh/ssh_config':
    source => "puppet:///modules/nebula/default/${facts['os']['distro']['codename']}/etc/ssh/ssh_config",
  }

  exec { 'divert pam.d/sshd':
    creates => '/etc/pam.d/sshd-defaults',
    timeout => 30,
    command => '/usr/bin/dpkg-divert --rename --divert /etc/pam.d/sshd-defaults --add /etc/pam.d/sshd',
    before  => File['/etc/pam.d/sshd-defaults'],
  }
  # Diverts file without moving. This is required if `sshd-defaults` already exists, but isn't safe unless
  # we're also writing `sshd-defaults` afterwords.
  exec { 'divert pam.d/sshd 2':
    # TODO: remove this exec once all existing hosts have been remediated.
    unless  => "/usr/bin/test `/usr/bin/dpkg-divert --truename /etc/pam.d/sshd` = '/etc/pam.d/sshd-defaults'",
    timeout => 30,
    command => '/usr/bin/dpkg-divert --no-rename --divert /etc/pam.d/sshd-defaults --add /etc/pam.d/sshd',
    before  => File['/etc/pam.d/sshd-defaults'],
    require => Exec['divert pam.d/sshd'],
  }

  # Reset /etc/pam.d/sshd-defaults to original distro config for /etc/pam.d/sshd.
  # TODO: This should be deleted once all existing hosts have been remediated.
  file { '/etc/pam.d/sshd-defaults':
    source => "puppet:///modules/nebula/default/${facts['os']['distro']['codename']}/etc/pam.d/sshd",
  }

  concat_file { '/etc/pam.d/sshd':
    require => File['/etc/pam.d/sshd-defaults'],
    # require => Exec['divert pam.d/sshd'],
  }

  concat_fragment { '/etc/pam.d/sshd: base':
    target  => '/etc/pam.d/sshd',
    order   => '01',
    content => @("EOT")
      # Managed by puppet (manifests/profile/networking/sshd)

      @include sshd-defaults
      | EOT
  }
}
