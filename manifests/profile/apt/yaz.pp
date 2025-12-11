# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Add apt repo for yaz
#
# @example
#   include nebula::profile::apt::yaz
class nebula::profile::apt::yaz {
  apt::source { 'yaz-official-stable':
    source_format => 'sources',
    location      => ['http://ftp.indexdata.dk/debian'],
    repos         => ['main'],
    keyring       => '/etc/apt/keyrings/yaz-indexdata.dk.gpg',
    include       => {
      'src' => true,
      'deb' => true,
    },
  }

  apt::keyring { 'yaz-indexdata.dk.gpg':
    source => 'puppet:///modules/nebula/apt/keyrings/yaz-indexdata.dk.gpg',
  }
}
