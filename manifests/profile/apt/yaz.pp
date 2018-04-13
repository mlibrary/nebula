# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Add apt repo for yaz
#
# @example
#   include nebula::profile::apt::yaz
class nebula::profile::apt::yaz {
  apt::source { 'yaz-official-stable':
    location => 'http://ftp.indexdata.dk/debian',
    repos    => 'main',
    include  => {
      'src' => true,
      'deb' => true,
    }
  }
}
