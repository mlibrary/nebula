
# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::haproxy::prereqs
#
# @example
#   include nebula::profile::haproxy::prereqs
class nebula::profile::haproxy::prereqs {
  package { 'haproxy':
    ensure => 'installed',
  }

  package { 'haproxyctl':
    ensure => 'installed',
  }

  service { 'haproxy':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/haproxy/services.d':
    ensure => 'directory'
  }
}
