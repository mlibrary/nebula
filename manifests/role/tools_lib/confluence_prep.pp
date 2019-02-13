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

  class { 'nebula::profile::tools_lib::jdk':
    oracle => true,
  }

#  class { 'confluence::service':
#    service_file_location => '/etc/systemd/system/confluence.service',
#    service_file_template => 'confluence/confluence.service.erb',
#    refresh_systemd       => true,
#  }

  class { 'confluence':
    require    => Class['nebula::profile::tools_lib::jdk'],
    javahome   => Class['nebula::profile::tools_lib::jdk']['java_home'],
    version    => '6.3.3', # ancient version we're moving away from
    installdir => '/opt/conflunce',
    homedir    => '/var/opt/confluence',
  }

  # will still need unit files
  # probably need to make '/' much larger
  # import ssl keys to java keystore
  # probably need to install mysql driver
}
