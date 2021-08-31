# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Fulcrum
#
# This is desiged to manage a Debian Server that hosts the Fulcrum project. 

class nebula::role::fulcrum {
  include nebula::role::minimum
  include nebula::profile::redis
  include nebula::profile::solr
  include nebula::profile::ruby
  include nebula::profile::fulcrum::base
  include nebula::profile::fulcrum::app
  include nebula::profile::fulcrum::apache
  include nebula::profile::fulcrum::mysql
}
