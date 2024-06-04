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
    location     => 'https://dl.yarnpkg.com/debian/',
    key          =>  {
      name   => 'yarnpkg.asc',
      source => 'https://dl.yarnpkg.com/debian/pubkey.gpg'
    },
    release      => 'stable',
    repos        => 'main',
    architecture => $::os['architecture'],
  }

  package { 'yarn':
    require => Apt::Source['yarn'],
  }

}
