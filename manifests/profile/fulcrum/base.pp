# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.


# Base profile for a Fulcrum host; sets up host aliases, etc.
class nebula::profile::fulcrum::base {
  host { 'localhost':
    host_aliases => ['fedora', 'mysql', 'redis', 'solr'],
    ip => '127.0.0.1',
  }

  host { $::hostname:
    host_aliases => [$::fqdn],
    ip           => $::ipaddress,
  }

  host { 'ip6-localhost':
    host_aliases => ['localhost', 'ip6-loopback'],
    ip           => '::1',
  }

  host { 'ip6-allnodes':
    ip => 'ff02::1',
  }

  host { 'ip6-allrouters':
    ip => 'ff02::2',
  }

}
