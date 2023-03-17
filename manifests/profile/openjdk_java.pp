# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::openjdk_java
#
class nebula::profile::openjdk_java (
  Array[String] $jdk_packages = ['openjdk-11-jdk-headless']
) {
  ensure_packages($jdk_packages)
}

