# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::confluence
#
# Configure Confluence for tools.lib
#
# @example
#   include nebula::profile::tools_lib::confluence

class nebula::profile::tools_lib::confluence (
  String $domain,
) {

  class { 'confluence':
    require      => [ Class['nebula::profile::tools_lib::jdk'], Class['nebula::profile::tools_lib::postgres'] ],
    javahome     => Class['nebula::profile::tools_lib::jdk']['java_home'],
    installdir   => '/opt/conflunce',
    homedir      => '/var/opt/confluence',
    jvm_xms      => '1G',
    jvm_xmx      => '4G', # min for stable operation
    tomcat_proxy => {
      scheme    => 'https',
      proxyName => $domain,
      proxyPort => '443',
    },
    context_path => '/confluence',
  }

}