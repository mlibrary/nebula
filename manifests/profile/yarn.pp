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
<<<<<<< HEAD
<<<<<<< HEAD
      id     => 'B90F6449FEBC20F00DB13ED8212659B22565CA86',
=======
>>>>>>> 4c5e426... added info for yarn repo
=======
      id     => 'B90F6449FEBC20F00DB13ED8212659B22565CA86',
>>>>>>> 9c77a2e... added apt key id
      source => 'https://dl.yarnpkg.com/debian/pubkey.gpg'
    },
    release      => 'stable',
    repos        => 'main',
    architecture => $::os['architecture'],
  }

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  package { 'yarn':
    require => Apt::Source['yarn'],
  }
=======
  package { ['yarn']: }
>>>>>>> 4c5e426... added info for yarn repo
=======
  package { ['yarn'] }
>>>>>>> a00ec19... syntax fix
=======
  package { ['yarn']: }
>>>>>>> 2319f52... revert syntax fix
=======
  package { 'yarn':
    require => Apt::Source['yarn'],
  }
>>>>>>> a92c049... added requirment for install after repo is set up

}
