# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost for fulcrum.org (extracted from www.lib, so some extraneous stuff)
#
# @example
#   include nebula::role::webhost::fulcrum_www_and_app
class nebula::role::webhost::fulcrum_www_and_app (
  String $private_address_template = '192.168.0.%s',
  String $shibboleth_config_source = 'puppet:///shibboleth-www-lib-prod-bullseye',
  Hash $hosts = {}
) {
  include nebula::role::umich
  include nebula::role::fulcrum::app_host
  include nebula::profile::www_lib::register_for_load_balancing

  # The perl profile is needed for monitor_pl to work, but it pulls in a
  # ton of stuff. We should probably allow for different haproxy http checks
  # for a service, and eliminate the perl/monitor_pl dependency here.
  include nebula::profile::www_lib::perl
  include nebula::profile::networking::firewall::http

  create_resources('host',$hosts)

  include nebula::profile::www_lib::apache::base
  include nebula::profile::www_lib::apache::fulcrum

  class { 'nebula::profile::shibboleth':
    config_source    => $shibboleth_config_source,
    watchdog_minutes => '*/30',
  }

  # Include a default vhost to catch monitoring requests by IP/fqdn.
  # This is here rather than in the profile because it would be duplicate
  # on www_lib_vm.
  class { 'nebula::profile::www_lib::vhosts::default':
    prefix => '',
    domain => 'fulcrum.org',
    ssl_cn => 'fulcrum.org',
  }

  cron {
    default:
      user => 'root',
    ;

    'purge apache access logs 1/2':
      hour    => 1,
      minute  => 7,
      command => '/usr/bin/find /var/log/apache2 -type f -mtime +14 -name "*log*" -exec /bin/rm {} \; > /dev/null 2>&1',
    ;

    'purge apache access logs 2/2':
      hour    => 1,
      minute  => 17,
      command => '/usr/bin/find /var/log/apache2 -type f -mtime +2  -name "*log*" ! -name "*log*gz" -exec /usr/bin/pigz {} \; > /dev/null 2>&1',
      require => Package['pigz'],
    ;
  }

  ensure_packages(['pigz'])
}
