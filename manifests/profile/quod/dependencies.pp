# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::quod::dependencies
#
# Install miscellaneous package dependencies for quod applications
#
# @example
#   include nebula::profile::quod::dependencies
class nebula::profile::quod::dependencies () {

  ensure_packages (
    [
      'libapache2-mod-cosign',
      'curl',
      'git',
      'emacs',
      'imagemagick',
      'openjdk-8-jre',
      'libaprutil1-dbd-oracle',
      'libapache2-mod-authz-umichlib',
      'oracle-instantclient12.1-devel',
    ]
  )


}
