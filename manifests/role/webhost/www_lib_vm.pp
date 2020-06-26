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

  @@nebula::haproxy::binding { "${::hostname} www-lib-testing":
      service       => 'www-lib-testing',
      https_offload => false,
      datacenter    => $::datacenter,
      hostname      => $::hostname,
      ipaddress     => $::ipaddress
  }

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
  include nebula::profile::unison

  class { 'nebula::profile::shibboleth':
    config_source    => 'puppet:///shibboleth-www_lib',
    startup_timeout  => 1800,
    watchdog_minutes => '*/30',
  }

  # nebula::usergroup { user groups for www-lib: }
}
