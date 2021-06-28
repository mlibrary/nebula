# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Archivematica
#
# This is an ubuntu server and is almost entirely managed through
# ansible instead of puppet. All puppet does is manage authorized keys
# and the firewall.
class nebula::role::archivematica {
  include nebula::role::minimum
  include nebula::profile::krb5
  include nebula::profile::afs
  include nebula::profile::duo
  include nebula::profile::networking
  include nebula::profile::tsm

  nebula::exposed_port { '200 HTTP Dashboard':
    port  => 80,
    block => 'umich::networks::campus_wired_and_wireless',
  }

  nebula::exposed_port { '200 HTTP Storage LIT':
    port  => 8000,
    block => 'umich::networks::staff',
  }

  nebula::exposed_port { '200 HTTP Storage Bentley':
    port  => 8000,
    block => 'umich::networks::bentley',
  }

  nebula::exposed_port { '100 SSH Bentley':
    port  => 22,
    block => 'umich::networks::bentley',
  }

}
