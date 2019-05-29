# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# MarcEdit server
#
# @example
#   include nebula::role::aleph::marcedit
class nebula::role::aleph::marcedit {
  include nebula::role::umich

  include nebula::profile::afs
  include nebula::profile::users

  include nebula::profile::apt::mono
  include nebula::profile::apt::yaz
}
