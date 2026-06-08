# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::quod::prod::apache2 {
  service { 'apache2': }

  file { '/etc/apache2':
    ensure  => 'directory',
    recurse => true,
    purge   => false,
    links   => 'manage',

    source  => 'puppet:///quod-apache/apache2',
    mode    => 'u+rwX,go+rX,go-w',
    owner   => 'root',
    group   => 'root',
    notify  => Service['apache2'],
  }

  file { '/etc/apache2/mods-available/auth_openidc.conf':
    source => 'puppet:///quod-apache/apache2/mods-available/auth_openidc.conf',
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    notify => Service['apache2'],
  }

  file { '/etc/logrotate.d/apache2':
    source => 'puppet:///quod-apache/logrotate.d/apache2',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }
}
