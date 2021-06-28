# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::slip
#
# Profile to add cron user called 'slip'
#
# @example
#   include nebula::profile::slip
class nebula::profile::hathitrust::slip (
) {
  nebula::usergroup { 'slip': }
}
