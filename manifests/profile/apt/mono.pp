# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Add apt repo for mono
#
# @example
#   include nebula::profile::apt::mono
# THIS IS BROKEN ON BULLSEYE, latest supported dists are buster and focal
# see: https://download.mono-project.com/repo/debian/index.html
class nebula::profile::apt::mono {
  apt::source { 'mono-official-stable':
    location => 'http://download.mono-project.com/repo/debian',
    release  => "stable-${::lsbdistcodename}",
    repos    => 'main',
    key      => {
      'name'   => 'mono-project.asc',
      'source' => 'https://download.mono-project.com/repo/xamarin.gpg',
    },
  }
}
