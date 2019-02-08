# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::adoptopenjdk
#
# Install OpenJDK 8 from the AdoptOpenJDK distribution
#
# @example
#   include nebula::profile::tools_lib::adoptopenjdk

class nebula::profile::tools_lib::adoptopenjdk (
) {
  java::oracle { 'jdk8' :
    ensure        => 'present',
    version_major => '8u202',
    version_minor => 'b08',
    url => 'https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u202-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u202b08.tar.gz',
    java_se       => 'jdk',
  }
}
