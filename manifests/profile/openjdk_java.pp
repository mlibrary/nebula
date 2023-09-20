# Copyright (c) 2023 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
#
# nebula::profile::openjdk_java
#
class nebula::profile::openjdk_java (
  Array[String] $jdk_packages = ['openjdk-11-jdk-headless'],
  String $default_jdk = 'openjdk-11-jdk-headless',
  String $base_alternative = 'java-11-openjdk-amd64',
  String $java_alternative = 'java-1.11.0-openjdk-amd64'
) {
  ensure_packages($jdk_packages)
  exec { 'ensure default java':
    command => "/usr/sbin/update-java-alternatives -s ${java_alternative}",
    unless => "/usr/bin/update-alternatives --query java | grep '^Value:.*${base_alternative}'",
    require => Package[$default_jdk]
  }
}

