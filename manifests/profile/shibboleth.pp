# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::shibboleth
#
# Install Shibboleth (Service Provider and Apache module)
#
# @param config_source Source URI for /etc/shibboleth content, typically a
#   fileserver path on the puppet-master.
# @param startup_timeout The time systemd will wait, in seconds, for startup
# @param watchdog_minutes How often to run ckshibd, as a "minutes" cron expression
#
# @example
#   class { 'nebula::profile::shibboleth':
#     config_source   => 'puppet:///shibboleth',
#     startup_timeout => 300,
#     watchdog_minutes => '*/5',
#   }
class nebula::profile::shibboleth (
  String $config_source,
  Integer $startup_timeout = 900,
  String $watchdog_minutes = '*/10',
) {
  include nebula::systemd::daemon_reload

  package {
    [
      'unixodbc',
    ]:
  }

  if $::lsbdistcodename == 'stretch' {
    # stretch: Shibboleth 2
    package {
      [
        'shibboleth-sp2-common',
        'shibboleth-sp2-utils',
        # locally-built -- odbc-mariadb isn't in stretch (AEIM-1678)
        'mariadb-unixodbc'
      ]:
    }

    # We require 'apache' here to make sure that this profile is used in
    # conjunction with a managed Apache installation, rather than just pulling
    # in an unmanaged package with APT.
    package { 'libapache2-mod-shib2':
      require => [Class['apache']],
    }

    service { 'shibd':
      ensure     => 'running',
      enable     => true,
      hasrestart => true,
      require    => [Package['shibboleth-sp2-utils'], Package['mariadb-unixodbc']]
    }
  } else {
    # buster, bullseye: Shibboleth 3
    package {
      [
        'shibboleth-sp-common',
        'shibboleth-sp-utils',
        'odbc-mariadb'
      ]:
    }

    # We require 'apache' here to make sure that this profile is used in
    # conjunction with a managed Apache installation, rather than just pulling
    # in an unmanaged package with APT.
    package { 'libapache2-mod-shib':
      require => [Class['apache']],
    }

    service { 'shibd':
      ensure     => 'running',
      enable     => true,
      hasrestart => true,
      require    => [Package['shibboleth-sp-utils'], Package['odbc-mariadb']]
    }
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


  file { '/etc/shibboleth':
    ensure  => 'directory',
    mode    => 'u=rw,u+X,g=r,g+X,o=r,o+X',
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    links   => 'follow',
    source  => $config_source
  }

  file { '/etc/shibboleth/shibboleth2.xml':
    mode         => '0440',
    owner        => '_shibd',
    group        => 'nogroup',
    source       => "${config_source}/shibboleth2.xml",
    validate_cmd => '/usr/sbin/shibd -t -c %'
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
  }

  file { '/etc/systemd/system/shibd.service.d/increase-timeout.conf':
    ensure  => 'file',
    content => "[Service]\nTimeoutStartSec=${startup_timeout}",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => [
      Class['nebula::systemd::daemon_reload'],
    ]
  }

  cron { 'shibd existence check':
    command => '/usr/local/bin/ckshibd',
    user    => 'root',
    minute  => $watchdog_minutes,
  }

  $http_files = lookup('nebula::http_files')
  file { '/usr/local/bin/ckshibd':
    ensure => 'present',
    mode   => '0755',
    source => "https://${http_files}/ae-utils/bins/ckshibd"
  }

}
