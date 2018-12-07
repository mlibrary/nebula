# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::groups
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include nebula::profile::groups
class nebula::profile::groups (
  Hash[String, Integer] $all_groups,
) {
  $all_groups.each |$group, $gid| {
    group { $group:
      gid => $gid,
    }
  }
}
