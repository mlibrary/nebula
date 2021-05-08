# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apt_mirror
#
# Profile for apt repo mirror
#
# @example
#   include nebula::profile::apt_mirror
class nebula::profile::apt_mirror (
) {

  ensure_packages(['debian-keyring','s3fs'], {'ensure' => 'present'})

  package { 'debmirror': }

  group { 'apt-mirror':
    ensure => 'present',
    system => 'true',
    gid    => '996',
  }

  user { 'apt mirror user':
    ensure     => 'present',
    name       => 'apt-mirror',
    comment    => 'apt mirror user',
    gid        => '996',
    groups     => ['apt-mirror'],
    home       => '/var/local/apt-mirror',
    password   => '!',
    shell      => '/bin/false',
    system     => 'true',
    uid        => '996',
    managehome => 'true',
  }

  file { '/usr/local/bin/apt-mirror-sync.sh':
    ensure => 'file',
    source => 'puppet:///modules/nebula/apt-mirror/apt-mirror-sync.sh',
    path   => '/usr/local/bin/apt-mirror-sync.sh',
    owner  => 'apt-mirror',
    group  => 'apt-mirror',
    mode   => '0770',
  }

  cron { 'apt mirror sync using debmirror':
    command => '/usr/local/bin/apt-mirror-sync.sh',
    user    => 'apt-mirror',
    minute  => '0',
    hour    => '4',
    weekday => 'SUN',
  }
}
