# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::tools_lib::confluence
#
# Configure Confluence for tools.lib
#
# @param domain The public domain name that confluence will listen on
# @param homedir The home directory to use for Confluence
# @param s3_backup_dest The S3 bucket where the confluence XML dump will be
# copied on a daily basis
#
# @example
#   class { 'nebula::profile::tools_lib::confluence':
#     domain         => 'atlassian.somewhere.edu'
#     s3_backup_dest => 's3://something/whatever'
#   }

class nebula::profile::tools_lib::confluence (
  String $domain,
  String $mail_recipient,
  String $homedir = '/var/opt/confluence',
  Optional[String] $s3_backup_dest = null
) {

  include nebula::profile::tools_lib::jdk

  class { 'confluence':
    require      => Class['nebula::profile::tools_lib::jdk'],
    javahome     => Class['nebula::profile::tools_lib::jdk']['java_home'],
    installdir   => '/opt/conflunce',
    homedir      => $homedir,
    jvm_xms      => '1G',
    jvm_xmx      => '4G', # min for stable operation
    tomcat_proxy => {
      scheme    => 'https',
      proxyName => $domain,
      proxyPort => '443',
    },
    context_path => '/confluence',
  }

  if($s3_backup_dest) {
    ensure_packages(['awscli'])

    cron { 'backup confluence xml dump to s3':
      command     => "/usr/bin/aws s3 cp --quiet ${homedir}/backups/backup.zip ${s3_backup_dest}/confluence.zip",
      user        => 'root',
      hour        => 3,
      minute      => 10,
      environment => ["MAILTO=${mail_recipient}"];
    }
  }

}
