# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# stand up apache server w/ dependencies for confluence and apache
#
# @example
#   include nebula::role::tools_lib
class nebula::role::tools_lib (
  String $domain,
  String $mail_recipient = lookup('nebula::automation_email')
) {

  include nebula::role::aws

  class { 'nebula::profile::tools_lib::apache':
    servername => $domain,
  }

  # fonts needed for jira and confluence
  package { 'fonts-dejavu-core': }
  package { 'fontconfig': }

  class { 'nebula::profile::tools_lib::postgres':
    mail_recipient =>  $mail_recipient,
  }

  class { 'nebula::profile::tools_lib::confluence':
    domain         => $domain,
    mail_recipient => $mail_recipient,
    require        => Class['nebula::profile::tools_lib::postgres'],
  }

  class { 'nebula::profile::tools_lib::jira':
    domain         => $domain,
    mail_recipient => $mail_recipient,
    require        => Class['nebula::profile::tools_lib::postgres'],
  }

}
