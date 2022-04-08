# Copyright (c) 2019-2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Webhost for fulcrum.org (extracted from www.lib, so some extraneous stuff)
#
# @example
#   include nebula::role::webhost::fulcrum_www_and_app
class nebula::role::webhost::fulcrum_www_and_app (
  String $private_address_template = '192.168.0.%s',
  Hash $hosts = {}
) {
  include nebula::role::umich
  include nebula::role::fulcrum::app_host
  include nebula::profile::www_lib::register_for_load_balancing
  include nebula::profile::networking::firewall::http

  create_resources('host',$hosts)

  include nebula::profile::www_lib::apache_minimum
  include nebula::profile::www_lib::fulcrum_apache

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
