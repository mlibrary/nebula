# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Configure the Shibboleth SP for Fulcrum in FastCGI mode.
# See also the nginx profile that depends on these services.
class nebula::profile::fulcrum::shibboleth {
  ensure_packages([
    'unixodbc',
    'shibboleth-sp-common',
    'shibboleth-sp-utils',
    'mariadb-unixodbc',
  ])

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

  file { '/etc/systemd/system/shibresponder.socket':
    content => template('nebula/profile/fulcrum/shibresponder.socket.erb'),
  }

  file { '/etc/systemd/system/shibresponder.service':
    content => template('nebula/profile/fulcrum/shibresponder.service.erb'),
  }

  file { '/etc/systemd/system/shibauthorizer.socket':
    content => template('nebula/profile/fulcrum/shibauthorizer.socket.erb'),
  }

  file { '/etc/systemd/system/shibauthorizer.service':
    content => template('nebula/profile/fulcrum/shibauthorizer.service.erb'),
  }

  service { 'shibd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => [Package['shibboleth-sp2-utils'], Package['mariadb-unixodbc']]
  }

  service { 'shibauthorizer.socket':
    enable  => true,
    require => Service['shibd'],
  }

  service { 'shibauthorizer.service':
    enable  => true,
    require => Service['shibd'],
  }

  service { 'shibresponder.socket':
    enable  => true,
    require => Service['shibd'],
  }

  service { 'shibresponder.service':
    enable  => true,
    require => Service['shibd'],
  }

}
