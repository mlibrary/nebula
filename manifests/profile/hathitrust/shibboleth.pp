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
      'mariadb-unixodbc',
      'libapache2-mod-shib2',
      'shibboleth-sp2-common',
      'shibboleth-sp2-utils'
    ]:
  }

  file { '/etc/odbcinst.ini':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    # Threading & pooling settings based on empirical testing to minimize crashes. 
    # Tested on Debian 8 with Shibboleth SP 2.5.3 and MySQL ODBC driver 5.1.10. 
    content => @("ODBCINST")
      [ODBC]
      Pooling         = Yes
      [MySQL]
      Description     = MySQL driver
      Driver          = libmaodbc.so
      Setup           = libodbcmyS.so
      Threading       = 3
      CPTimeout       = 120
      UsageCount      = 1
      |ODBCINST
  }

  service { 'shibd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => [Package['shibboleth-sp2-utils'], Package['mariadb-unixodbc']]
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
    mode   => '0440',
    owner  => '_shibd',
    group  => 'nogroup',
    notify => Service['shibd'],
    source => 'puppet:///shibboleth/shibboleth2.xml'
  }

  file { '/etc/systemd/system/shibd.service.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  # Reduce per-thread stack-size from the default of 8M to 512K, since we are
  # running in prefork mode. Without this setting, shibd will "waste" up to
  # 8M*<max apache child count> of RAM to interact with Apache

  file { '/etc/default/shibd':
    ensure  => 'file',
    content => 'ulimit -s 512',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Service['shibd']
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

  cron { 'shibd existence check':
    command => '/usr/local/bin/ckshibd',
    user    => 'root',
    minute  => '*/10',
  }

  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/ckshibd':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/ckshibd"
  }

}
