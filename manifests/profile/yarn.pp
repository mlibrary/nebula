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
      id     => '72ECF46A56B4AD39C907BBB71646B01B86E50310',
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
