# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::etc_hosts (
  Array[String] $lines = [],
) {
  file { '/etc/hosts':
    content => template('nebula/profile/etc_hosts/hosts.erb'),
  }
}
