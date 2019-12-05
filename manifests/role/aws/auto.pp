# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Include basic aws role and the role listed for the node in EC2 tag "role"
#
# @example
#   include nebula::role::aws::auto
class nebula::role::aws::auto {
  if $::ec2_tag_role {
    include Class[$::ec2_tag_role]
  } else {
    fail('no ec2 role tag defined')
  }
}
