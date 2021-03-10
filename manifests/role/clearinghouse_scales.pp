# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::clearinghouse_scales
#
# Scales host working in conjunction with clearinghouse production
#
# Note: There are additional steps that are done manually.
# which include passwd file entries, app accounts, sudo access,
# keys, pip packages, git repos, etc. This file only provides
# a baseline.
#
# @example
#   include nebula::role::clearinghouse_scales
class nebula::role::clearinghouse_scales {
  include nebula::role::aws
  include nebula::profile::krb5
  include nebula::profile::duo
  include nebula::profile::scales
}
