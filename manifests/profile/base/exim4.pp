# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::exim4
#
# A description of what this class does
#
# @example
#   include nebula::profile::base::exim4
class nebula::profile::base::exim4 (
  String $relay_domain,
  String $root_email,
) {
  service { 'exim4':
    ensure  => 'running',
    enable  => true,
    require => Package['exim4'],
  }

  ['aliases', 'email-addresses'].each |$filename| {
    file_line { "/etc/${filename}: root email":
      path    => "/etc/${filename}",
      match   => '^root: ',
      line    => "root: ${root_email}",
      require => Package['exim4'],
      notify  => Exec['load new email aliases'],
    }
  }

  file { '/etc/mailname':
    content => "${::fqdn}\n",
    notify  => Exec['update exim4 config'],
  }

  file { '/etc/exim4/update-exim4.conf.conf':
    content => template('nebula/profile/base/update-exim4.conf.conf.erb'),
    require => Package['exim4'],
    notify  => Exec['update exim4 config'],
  }

  package { 'exim4': }

  exec { 'load new email aliases':
    command     => '/usr/bin/newaliases',
    refreshonly => true,
  }

  exec { 'update exim4 config':
    command     => '/usr/sbin/update-exim4.conf',
    refreshonly => true,
    notify      => Service['exim4'],
  }
}
