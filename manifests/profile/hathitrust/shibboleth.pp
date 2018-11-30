# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::shibboleth
#
# Install shibboleth for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::shibboleth
class nebula::profile::hathitrust::shibboleth () {
  include nebula::profile::hathitrust::apache
  include nebula::systemd::daemon_reload

  package {
    [
      'unixodbc',
      'libapache2-mod-shib2',
      'shibboleth-sp2-common',
      'shibboleth-sp2-utils'
    ]:
  }

  service { 'shibd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['shibboleth-sp2-utils'],
  }

  file { '/etc/shibboleth':
    ensure  => 'directory',
    mode    => '0775',
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    links   => 'follow',
    notify  => Service['shibd'],
    source  => 'puppet:///shibboleth'
  }

  file { '/etc/shibboleth/shibboleth2.xml':
    mode  => '0440',
    owner => '_shibd',
    group => 'nogroup'
  }

  file { '/etc/systemd/system/shibd.service.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  file { '/etc/systemd/system/shibd.service.d/increase-timeout.conf':
    ensure  => 'file',
    content => "[Service]\nTimeoutStartSec=900",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => [
      Class['nebula::systemd::daemon_reload'],
      Service['shibd']
    ]
  }
}
