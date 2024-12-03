# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::fulcrum::solr

class nebula::profile::fulcrum::solr {

  $jdk_version = lookup('nebula::jdk_version')
  $java_home = "/usr/lib/jvm/temurin-${jdk_version}-jre-${::os['architecture']}"

  class { 'nebula::profile::solr':
    base => '/var/lib/solr',
    home => '/var/lib/solr/data',
    logs => '/var/log/solr',
  }

  ensure_packages(["temurin-${jdk_version}-jre"])

  class { 'nebula::profile::openjdk_java':
    jdk_packages     => ["temurin-${jdk_version}-jre"],
    default_jdk      => "temurin-${jdk_version}-jre",
    base_alternative => $java_home,
    java_alternative => "temurin-${jdk_version}-jre-amd64",
  }

  file { '/etc/environment':
      content => inline_template("JAVA_HOME=${java_home}")
      ;
  }

  file {
    ['/var/lib/solr/data/cores']:
      ensure => 'directory',
      owner  => 'solr',
      group  => 'solr',
    ;
  }
}
