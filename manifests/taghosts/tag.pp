# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::taghosts::tag (
  String $order = '100',
) {
  @@concat::fragment { "taghosts ${::networking['fqdn']} ${order} ${title}":
    tag     => 'taghosts',
    target  => '/var/lib/ae/active-servers',
    content => " ${title}",
  }
}
