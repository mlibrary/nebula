# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::openjdk_java
#
class nebula::profile::search::openjdk_java (
) {
  ensure_packages('default-jdk-headless')
}
