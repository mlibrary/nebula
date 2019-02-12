# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::jira
#
# Configure Confluence for tools.lib
#
# @example
#   include nebula::profile::tools_lib::jira

class nebula::profile::tools_lib::jira (
  String $domain,
) {

  class { 'jira':
    require                   => [ Class['nebula::profile::tools_lib::jdk'], Class['nebula::profile::tools_lib::postgres'] ],
    javahome                  => Class['nebula::profile::tools_lib::jdk']['java_home'],
    download_url              => 'https://www.atlassian.com/software/jira/downloads/binary',
    installdir                => '/opt/jira',
    homedir                   => '/var/opt/jira',
    dbuser                    => 'jira',
    dbpassword                => lookup('nebula::profile::tools_lib::db::jira::password'),
    jvm_xms                   => '1G',
    jvm_xmx                   => '4G', # min for stable operation
    tomcat_max_threads        => '48', # don't exhaust db connection limit
    enable_connection_pooling => true, # add serveral required settings to dbconfig.xml
    proxy                     => {
      scheme            => 'https',
      proxyName         => $domain,
      proxyPort         => '443',
      relaxedPathChars  => '[]|',
      relaxedQueryChars => '[]|{}^&#x5c;&#x60;&quot;&lt;&gt;',
    },
    contextpath               => '/jira',
    jira_config_properties    => {
      'ops.bar.group.size.opsbar-transitions' => '4', # tidy up transitions list over tickets
      'jira.websudo.timeout'                  => '30', # increase timeout for admin tasks
    }
  }

}