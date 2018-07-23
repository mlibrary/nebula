# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::users
#
# Provision users and groups.
#
# @example
#   include nebula::profile::users
class nebula::profile::users {
  lookup('nebula::users::groups').each |$group, $gid| {
    group { $group:
      gid => $gid,
    }
  }

  lookup('nebula::users::sudoers').each |$name, $data| {
    $values = {'group' => lookup('nebula::users::default_group')} + $data

    user { $name:
      comment    => $values['comment'],
      gid        => $values['group'],
      uid        => $values['uid'],
      home       => $values['home'],
      managehome => false,
      shell      => '/bin/bash',
      groups     => ['sudo'],
    }
  }
}
