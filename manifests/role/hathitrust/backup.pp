# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# backup servers for hathitrust.org
#
# @example
#   include nebula::role::hathitrust::backup
class nebula::role::hathitrust::backup (String $private_address_template = '192.168.0.%s') {
  include nebula::role::hathitrust

  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }

  class { 'nebula::profile::hathitrust::mounts':
    smartconnect_mounts => ['/htapps','/htprep'],
    readonly            => true
  }

}
