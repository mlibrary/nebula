# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::letsencrypt (
  String $email = lookup('nebula::profile::base::contact_email'),
) {
  class { 'letsencrypt':
    email => $email,
  }
}
