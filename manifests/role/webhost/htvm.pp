# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::htvm
class nebula::role::webhost::htvm (String $private_address_template = '192.168.0.%s') {
  include nebula::role::hathitrust

  # not ready for this yet
  # nebula::balanced_frontend { 'htvm': }

  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }

  include nebula::profile::networking::firewall::http

  include nebula::profile::hathitrust::hosts
  include nebula::profile::hathitrust::mounts

  include nebula::profile::geoip
  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl
  include nebula::profile::hathitrust::php

  class { 'nebula::profile::hathitrust::imgsrv':
    num_proc => 10,
    sdrview  => 'full'
  }

  include nebula::profile::hathitrust::shibboleth
  include nebula::profile::hathitrust::apache
  include nebula::profile::hathitrust::unison

  nebula::usergroup { 'htprod': }
}
