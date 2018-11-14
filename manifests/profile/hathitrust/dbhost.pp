# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::dbhost
#
# Install database host alias for HathiTrust
#
# In the future this could rely on exported resources and also open a firewall
# entry on the mysql host, but that is dependent on having a role for mysql.
#
# @example
#   include nebula::profile::hathitrust::dbhost
class nebula::profile::hathitrust::dbhost (String $address) {
  host { 'mysql-sdr':
    comment => 'HathiTrust MySQL server (private network)',
    ip      => $address
  }
}
