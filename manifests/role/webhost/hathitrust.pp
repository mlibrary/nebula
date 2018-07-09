# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::hathitrust
class nebula::role::webhost::hathitrust {
  nebula::balanced_frontend { 'hathitrust': }
  include nebula::role::hathitrust
}
