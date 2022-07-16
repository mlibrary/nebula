# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::dependencies
#
# Install miscellaneous package dependencies for www_lib applications
#
# @example
#   include nebula::profile::www_lib::dependencies
class nebula::profile::www_lib::dependencies () {

  ensure_packages (
    [
      'libapache2-mod-cosign',
      'curl',
      'git',
      'emacs',
      'imagemagick',
      'openjdk-11-jre',
    ]
  )


}
