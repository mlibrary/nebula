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
    location     => 'https://download.docker.com/linux/debian',
    architecture => $facts['os']['architecture'],
    release      => $::lsbdistcodename,
    repos        => 'stable',
    key          => {
      id     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
      source => 'https://download.docker.com/linux/debian/gpg',
    },
    include      => {
      src => false,
    },
  }
}
