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
  # Test::NoWarnings runs an extra test at exit by default, which fails itself
  # out unless you have an actual test suite, so we have to tell it to skip it.
  if $title == 'Test::NoWarnings' {
    $expression = "$Test::NoWarnings::do_end_test = 0"
  } else {
    $expression = "1"
  }

  exec { "CPAN - ${title}":
    command => "/usr/bin/cpan -i ${title}",
    unless  => "/usr/bin/env perl -M${title} -e '${expression}' >/dev/null 2>&1"
  }
}
