# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Virtual CIFS credentials files
#
# @param users List of CIFS users whose credentials might be required
class nebula::cifs::credentials (
  Array[String] $users = [],
) {
  $users.each |$user| {
    @file { "/etc/default/${user}-credentials":
      source => "puppet:///cifs-credentials/${user}-credentials",
      mode   => '0400',
      owner  => 'root',
      group  => 'root'
    }
  }
}
