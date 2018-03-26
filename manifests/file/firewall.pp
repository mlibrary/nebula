# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::file::firewall
#
# Create a firewall file.
#
# @example
#   nebula::file::firewall { 'namevar': }
define nebula::file::firewall(
  Array $rules = [],
) {
  file { $title:
    content => template('nebula/file/firewall.erb'),
  }
}
