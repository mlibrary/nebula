# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::htvm::prod::primary
class nebula::role::webhost::htvm::global_primary {
  include nebula::role::webhost::htvm::site_primary
  include nebula::profile::hathitrust::cron::statistics
  include nebula::profile::hathitrust::cron::catalog

  cron {
    'wordpress cron':
      user    =>  'nobody',
      minute  => 0,
      command => '/usr/bin/curl -s https://www.hathitrust.org/wp-cron.php --resolve "www.hathitrust.org:443:127.0.0.1"';
  }
}
