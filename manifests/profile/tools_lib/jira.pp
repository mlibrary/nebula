# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::jira
#
# Configure JIRA for tools.lib
#
# @param domain The public domain name that jira will listen on
# @param homedir The home directory to use for jira
# @param s3_backup_dest The S3 bucket where the jira XML dump will be
# copied on a daily basis
#
# @example
#   class { 'nebula::profile::tools_lib::jira':
#     domain         => 'atlassian.somewhere.edu'
#     s3_backup_dest => 's3://something/whatever'
#   }

class nebula::profile::tools_lib::jira (
  String $domain,
  String $mail_recipient,
  String $homedir = '/var/opt/jira',
  Optional[String] $s3_backup_dest = null
) {

  include nebula::profile::tools_lib::jdk

  class { 'jira':
    require                   => Class['nebula::profile::tools_lib::jdk'],
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
    },
    contextpath               => '/jira',
    jira_config_properties    => {
      'ops.bar.group.size.opsbar-transitions' => '4', # tidy up transitions list over tickets
      'jira.websudo.timeout'                  => '30', # increase timeout for admin tasks
    }
  }

  if($s3_backup_dest) {
    ensure_packages(['awscli'])

    cron {
      default:
        environment => ["MAILTO=${mail_recipient}"],
        user        => 'root';

      'backup jira xml dump to s3':
        command => "/usr/bin/aws s3 cp --quiet ${homedir}/export/`date +\\%Y\\%m\\%d`.zip ${s3_backup_dest}/jira.zip",
        hour    => 3,
        minute  => 20;

      'remove old jira backup':
        command => "/bin/rm ${homedir}/export/`date +\\%Y\\%m\\%d`.zip",
        hour    => 23,
        minute  => 50
    }
  }
}
