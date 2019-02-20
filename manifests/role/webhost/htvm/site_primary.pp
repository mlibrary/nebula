# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting hathitrust.org
#
# @example
#   include nebula::role::webhost::htvm::prod::primary
class nebula::role::webhost::htvm::site_primary {
  include nebula::role::webhost::htvm::prod
  include nebula::profile::hathitrust::cron::mdp_misc
}
