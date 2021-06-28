# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost hosting www.lib.umich.edu
#
# @example
#   include nebula::role::webhost::www_lib
class nebula::role::webhost::www_lib_vm (
  String $private_address_template = '192.168.0.%s',
  Hash $hosts = {}
) {
  include nebula::role::umich
  include nebula::profile::elastic::filebeat::prospectors::clickstream
  include nebula::profile::www_lib::register_for_load_balancing

  class { 'nebula::profile::networking::private':
    address_template => $private_address_template
  }

  include nebula::profile::networking::firewall::http
  include nebula::profile::www_lib::mounts

  create_resources('host',$hosts)

  include nebula::profile::geoip
  #include nebula::profile::www_lib::php73
  include nebula::profile::www_lib::dependencies
  include nebula::profile::www_lib::perl
  include nebula::profile::www_lib::php
  include nebula::profile::www_lib::apache
  include nebula::profile::www_lib::cron

  class { 'nebula::profile::shibboleth':
    config_source    => 'puppet:///shibboleth-www_lib',
    watchdog_minutes => '*/30',
  }

  include nebula::profile::krb5
  include nebula::profile::afs
  include nebula::profile::www_lib::users
}
