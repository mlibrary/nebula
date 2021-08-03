# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Fulcrum
#
# This is desiged to manage a Debian Server that hosts the Fulcrum project. 

class nebula::role::fulcrum {
  include nebula::role::minimum

  include nebula::role::redis
  include nebula::role::mysql
  include nebula::role::solr

}
