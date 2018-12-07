# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::virtual::users
#
# This adds virtual user resources for every user we'll ever want to
# define. For this to work, you should have the following in your
# hieradata:
#
#     nebula::virtual::users::default_group: staff # or user or whatever
#     nebula::virtual::users::all_users:
#       johnjson:
#         comment: John Johnson
#         uid: 12345
#         home: /home/johnjson
#       hotjon:
#         comment: Jon "Hot Jon" Lieukasiewicz
#         uid: 12346
#         home: /home/hotjon
#       notjon:
#         comment: Daniel "I Love CSH" Daniels
#         uid: 12347
#         home: /home/notjon
#         shell: /bin/csh
#
# This won't actually create any of them, but it will create virtual
# resources for them so that any other class can realize them just with
# the username. That way, the same users can be required in more than
# one place without having to define it in more than one place, because
# it's defined here.
#
# @example
#   include nebula::virtual::users
class nebula::virtual::users(
  Hash   $all_users,
  String $default_group,
) {
  include nebula::profile::groups
  $membership = inverted_hashlist('nebula::usergroup::membership')

  $all_users.each |$username, $data| {
    @user {
      default:
        ensure     => 'present',
        gid        => $default_group,
        managehome => false,
        shell      => '/bin/bash',
        groups     => $membership[$username],
      ;

      $username:
        *          => $data,
      ;
    }
  }
}
