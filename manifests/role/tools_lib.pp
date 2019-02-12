# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# stand up apache server w/ dependencies for confluence and apache
#
# vhost name is: tools.lib.umich.edu
#
#
# @example
#   include nebula::role::tools_lib
class nebula::role::tools_lib (
  String $domain,
) {

  include nebula::role::aws

  class { 'nebula::profile::tools_lib::apache':
    servername => $domain,
  }
  include nebula::profile::tools_lib::postgres

  include nebula::profile::tools_lib::jdk

  # fonts needed for jira and confluence
  package { 'fonts-dejavu-core': }
  package { 'fontconfig': }

  class { 'nebula::profile::tools_lib::confluence':
    domain  => $domain,
  }

  class { 'nebula::profile::tools_lib::jira':
    domain  => $domain,
  }

}