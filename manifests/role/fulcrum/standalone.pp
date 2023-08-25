# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Fulcrum
#
# This is desiged to manage a Debian Server that hosts the Fulcrum project, with all of the dependencies and services included. 

class nebula::role::fulcrum::standalone {
  $jdk_version = '11'

  include nebula::role::minimum
  include nebula::profile::ruby
  include nebula::profile::fulcrum::base
  include nebula::profile::fulcrum::hosts
  include nebula::profile::fulcrum::app
  include nebula::profile::fulcrum::demofedora
  include nebula::profile::fulcrum::logrotate
  include nebula::profile::fulcrum::mysql
  include nebula::profile::fulcrum::demomysql
  include nebula::profile::fulcrum::nginx
  include nebula::profile::fulcrum::redis
  include nebula::profile::fulcrum::shibboleth
  include nebula::profile::fulcrum::solr
}
