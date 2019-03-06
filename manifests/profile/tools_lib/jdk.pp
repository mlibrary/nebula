# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::jdk
#
# Install OpenJDK 8 from AdoptOpenJDK distribution
#
# @param version_major The major version (in 8uXYZ format)
# @param version_minor The minor version (in bXY format)
# @param cert_name: cert to add to java keystore
# @param java_home Not actually used; just here to expose the install base as an attribute
class nebula::profile::tools_lib::jdk (
  String  $version_major,
  String  $version_minor,
  String  $cert_name,
  String  $java_home     = "/usr/lib/jvm/jdk${version_major}-${version_minor}",
) {
  $url = "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk${version_major}-${version_minor}/OpenJDK8U-jdk_x64_linux_hotspot_${version_major}${version_minor}.tar.gz"

  java::oracle { 'jdk8':
    ensure        => 'present',
    java_se       => 'jdk',
    version_major => $version_major,
    version_minor => $version_minor,
    url           => $url,
  }

  $http_files = lookup('nebula::http_files')
  $cert_file  = "/etc/ssl/certs/${cert_name}"

  file { $cert_file:
    ensure => 'present',
    mode   => '0644',
    source => "https://${http_files}/${cert_name}",
  }

  java_ks { 'ITS ActiveDirectory Root certificate':
    ensure      => latest,
    require     => [
      File[$cert_file],
      Java::Oracle['jdk8'],
    ],
    name        => $cert_name,
    certificate => $cert_file,
    path        => "${java_home}/bin",
    target      => "${java_home}/jre/lib/security/cacerts",
    password    => 'changeit',
  }
}
