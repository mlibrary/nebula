# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::www_lib::dependencies
#
# Install miscellaneous package dependencies for www_lib applications
#
# @example
#   include nebula::profile::www_lib::dependencies
class nebula::profile::www_lib::dependencies {
  $jdk_version = lookup('nebula::jdk_version')
  if $jdk_version == '8' {
    $java_source = 'temurin'
  } else {
    $java_source = 'openjdk'
  }

  ensure_packages (
    [
      'curl',
      'git',
      'emacs',
      'imagemagick',
      "${java_source}-${jdk_version}-jre",
    ]
  )
}
