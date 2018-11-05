# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::apache
#
# Install apache for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::apache
class nebula::profile::hathitrust::apache () {
  package { [
      'apache2',
# default?
#      'apache2-mpm-prefork',
# removed, will use fcgid or proxy?
#      'libapache2-mod-fastcgi',
    ]:
  }
}
