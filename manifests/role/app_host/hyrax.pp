# Copyright (c) 2018-2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::app_host::hyrax
#
# Standalone hyrax application host including apache, mysql, fedora, 
# redis, solr
#
# @example
#   include nebula::role::app_host::hyrax
class nebula::role::app_host::hyrax {
  include nebula::role::umich

  include nebula::profile::ruby
  include nebula::profile::nodejs

  include nebula::profile::named_instances
  include nebula::profile::named_instances::apache

  include nebula::profile::mysql
  include nebula::profile::redis
  include nebula::profile::solr
}
