# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# stand up apache server w/ dependancies for confluence, both old and new
# versions, backed by mysql rather than postgres
#
# vhost name is: prep.tools.lib.umich.edu
#
# *** Specifically for export/process of confluence backups ***
# Background: confluence XML dumps are not to be moved between versions, s

# Build a Confluence staging box w/ mysql and both new and old versions of
# confluence where we can:
#  * import a confluence mysqldump
#  * execute mysql db migrations to current confluence
#  * generate an XML dump we can move to the new production confluence
#
# @example
#   include nebula::role::tools_lib::confluence_prep
class nebula::role::tools_lib::confluence_prep {

  class { 'nebula::profile::tools_lib::apache':
    servername => 'prep.tools.lib.umich.edu'
  }
  include nebula::profile::tools_lib::mysql

  java::oracle { 'jdk8' :
    ensure        => 'present',
    version_major => '8u192', # the most recent
    version_minor => 'b12', # generally dictated by major version, see oracle website
    url_hash      => '750e1c8617c5452694857ad95c3ee230', # scrape from oracle website
    java_se       => 'jdk',
  }

#  class { 'confluence::service':
#    service_file_location => '/etc/systemd/system/confluence.service',
#    service_file_template => 'confluence/confluence.service.erb',
#    refresh_systemd       => true,
#  }

  class { 'confluence':
    javahome   => '/usr/lib/jvm/jdk1.8.0_192', # must match java version above
    version    => '6.3.3', # ancient version we're moving away from
    installdir => '/opt/conflunce',
    homedir    => '/var/opt/confluence',
  }

  # will still need unit files
  # probably need to make '/' much larger
  # import ssl keys to java keystore
  # probably need to install mysql driver
}
