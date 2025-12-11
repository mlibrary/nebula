# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::yarn
#
# Installs Yarn from Official repositories.
class nebula::profile::yarn (
) {
  apt::source { 'yarn':
    source_format => 'sources',
    location      => ['https://dl.yarnpkg.com/debian/'],
    release       => 'stable',
    repos         => ['main'],
    architecture  => $facts['os']['architecture'],
    keyring       => '/etc/apt/keyrings/yarnpkg.asc',
  }

  apt::keyring { 'yarnpkg.asc':
    source => 'puppet:///modules/nebula/apt/keyrings/yarnpkg.asc',
  }

  package { 'yarn':
    require => Apt::Source['yarn'],
  }
}
