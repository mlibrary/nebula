# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::quod::dependencies::packages
#
# Install miscellaneous package dependencies for quod applications
#
# @example
#   include nebula::profile::quod::dependencies::packages
class nebula::profile::quod::dependencies::packages () {
  ensure_packages (
    [
      'curl',
      'emacs',
      'git',
      'imagemagick',
      'libapache2-mod-authz-umichlib',
      'libapache2-mod-cosign',
      'libaprutil1-dbd-oracle',
      'openjdk-8-jre',
      'oracle-instantclient12.1-basic',
      'oracle-instantclient12.1-devel',
    ]
  )
}
