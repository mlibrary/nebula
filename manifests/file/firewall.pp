# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::file::firewall
#
# Create a firewall file.
#
# @param rules Rules to add to the firewall
#
# @example
#   nebula::file::firewall { '/etc/firewall.ipv4':
#     rules => [
#       '-A INPUT -p tcp -s 10.1.1.1 -j ACCEPT',
#       '-A INPUT -p tcp -s 10.2.2.2 -j ACCEPT',
#     ],
#   }
define nebula::file::firewall(
  Array $rules = [],
) {
  file { $title:
    content => template('nebula/file/firewall.erb'),
  }
}
