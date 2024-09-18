# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::managed_known_hosts {
  concat { '/etc/ssh/ssh_known_hosts': }

  # See nebula::profile::known_host_public_keys
  Concat_fragment <<| tag == 'known_host_public_keys' |>>
}
