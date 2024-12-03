# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Add apt repo for mono
#
# @example
#   include nebula::profile::apt::mono
class nebula::profile::apt::mono {
  # default to buster since no newer release is available
  # check here to see if list of supported releases updated:
  # https://download.mono-project.com/repo/debian/index.html
  warning("nebula::profile::apt::mono: defaulting to apt repo dist 'buster'")
  $apt_release = 'buster'

  apt::source { 'mono-official-stable':
    location => 'https://download.mono-project.com/repo/debian',
    release  => "stable-${apt_release}",
    repos    => 'main',
    key      => {
      'name'   => 'mono-project.asc',
      'source' => 'https://download.mono-project.com/repo/xamarin.gpg',
    },
  }
}
