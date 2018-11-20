# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::cpan
#
# Install a CPAN module
#
# @example
#   nebula::cpan { 'Test::More': }
define nebula::cpan {
  exec { "CPAN - ${title}":
    command => "/usr/bin/cpan -i ${title}",
    unless => "/usr/bin/env perl -M${title} -e1 >/dev/null 2>&1",
  }
}
