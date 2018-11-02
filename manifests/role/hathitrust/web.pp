# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# HathiTrust production
#
# @example
#   include nebula::role::hathitrust::web
class nebula::role::hathitrust::web {
  include nebula::role::hathitrust

  include nebula::profile::geoip
  include nebula::profile::hathitrust::dependencies

  include nebula::profile::hathitrust::apache
  include nebula::profile::hathitrust::perl
  include nebula::profile::hathitrust::php
  include nebula::profile::hathitrust::shibboleth
  include nebula::profile::hathitrust::unison

}
