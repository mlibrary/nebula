# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Provision all users belonging to a group.
#
# @example Provision all sudoers
#   nebula::usergroup { 'sudo': }
define nebula::usergroup(
) {
  $membership = lookup('nebula::usergroup::membership')
  include nebula::virtual::users

  if $title in $membership {
    $membership[$title].each |$user| {
      realize User[$user]
    }
  }
}
