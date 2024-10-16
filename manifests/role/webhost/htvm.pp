# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::htvm
class nebula::role::webhost::htvm (
  String $shibboleth_config_source = 'puppet:///shibboleth'
) {
  include nebula::role::hathitrust

  include nebula::profile::hathitrust::networking

  include nebula::profile::networking::firewall::http

  include nebula::profile::hathitrust::hosts
  include nebula::profile::hathitrust::mounts

  include nebula::profile::hathitrust::dependencies
  include nebula::profile::hathitrust::perl
  include nebula::profile::hathitrust::php
  include nebula::profile::hathitrust::babel_logs

  class { 'nebula::profile::hathitrust::imgsrv':
    sdrview  => 'full'
  }

  include nebula::profile::hathitrust::apache
  include nebula::profile::unison

  class { 'nebula::profile::shibboleth':
    config_source    => $shibboleth_config_source,
    startup_timeout  => 1800,
    watchdog_minutes => '*/30',
  }

  nebula::usergroup { 'htprod': }

  # for HathiTrust deployment scripts
  package { 'rdist': }
}
