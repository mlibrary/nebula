# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::shibboleth
#
# Install shibboleth for HathiTrust applications
#
# @example
#   include nebula::profile::hathitrust::shibboleth
class nebula::profile::hathitrust::shibboleth () {
  include nebula::profile::hathitrust::apache

  package {
    [
      'libmyodbc',
      'unixodbc',
      'libapache2-mod-shib2'
    ]:
  }
}
