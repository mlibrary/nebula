# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Let's Encrypt System Requirements
#
# This installs certbot and sets it up with our contact email. It also
# opens port 80 to the world, which is required for verifying ownership.
class nebula::profile::letsencrypt (
  String $email = lookup('nebula::profile::base::contact_email'),
) {
  class { 'letsencrypt':
    email => $email,
  }

  firewall { '200 HTTP':
    proto  => 'tcp',
    dport  => 80,
    state  => 'NEW',
    action => 'accept',
  }
}
