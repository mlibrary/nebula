# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::jdk
#
# Install OpenJDK 8 from either Oracle or AdoptOpenJDK distribution
#
# @param version_major The major version (in 8uXYZ format)
# @param version_minor The minor version (in bXY format)
# @param url_hash The release hash for URL construction; only used for Oracle downloads
# @param java_home Not actually used; just here to expose the install base as an attribute
# @param oracle When true, download from Oracle website
class nebula::profile::tools_lib::jdk (
  String  $version_major = '8u202',
  String  $version_minor = 'b08',
  String  $java_home     = '/usr/lib/jvm/jdk1.8.0_202',
  Boolean $oracle        = false,
  String  $url_hash      = '1961070e4c9b4e26a04e7f5a083f551e', # as extracted from Oracle download links
) {
  $url = $oracle ? {
    true => undef,
    default => "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk${version_major}-${version_minor}/OpenJDK8U-jdk_x64_linux_hotspot_${version_major}${version_minor}.tar.gz",
  }

  java::oracle { 'jdk8':
    ensure        => 'present',
    java_se       => 'jdk',
    version_major => $version_major,
    version_minor => $version_minor,
    url           => $url,
    url_hash      => $url_hash,
  }

  $http_files = lookup('nebula::http_files')
  $cert_name  = 'its-dc02.adsroot.itcs.umich.edu.crt'
  $cert_file  = "/etc/ssl/certs/${cert_name}"

  file { $cert_file:
    ensure => 'present',
    mode   => '0644',
    source => "https://${http_files}/${cert_name}",
  }

  java_ks { 'ITS ActiveDirectory Root certificate':
    ensure      => latest,
    require     => File[$cert_file],
    name        => $cert_name,
    certificate => $cert_file,
    path        => "${java_home}/bin",
    target      => "${java_home}/jre/lib/security/cacerts",
    password    => 'changeit',
  }
}
