# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::containerd {
  service { 'containerd':
    require => Package['containerd.io'],
  }

  package { 'containerd.io':
    require => Apt::Source['docker'],
  }

  apt::source { 'docker':
    source_format => 'sources',
    location      => ['https://download.docker.com/linux/debian'],
    architecture  => $facts['os']['architecture'],
    release       => $facts['os']['distro']['codename'],
    repos         => ['stable'],
    keyring       => '/etc/apt/keyrings/docker.asc',
    include       => {
      src => false,
    },
  }

  apt::keyring { 'docker.asc':
    source => 'puppet:///modules/nebula/apt/keyrings/docker.asc',
  }

  file { '/etc/containerd/config.toml':
    content => template('nebula/profile/containerd/config.toml.erb'),
    notify  => Service['containerd']
  }

  file { '/etc/containerd':
    ensure => 'directory'
  }
}
