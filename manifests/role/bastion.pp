# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::bastion {
  include nebula::role::minimum

  include nebula::profile::bolt
  include nebula::profile::root_ssh_private_keys
  include nebula::profile::interactive

  # These three are effectively the requirements for getting user login
  # with kerberos and duo.
  include nebula::profile::duo
  include nebula::profile::krb5
  include nebula::profile::networking
}
