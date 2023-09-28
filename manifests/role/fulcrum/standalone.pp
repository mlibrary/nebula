# Copyright (c) 2021-2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Fulcrum
#
# This is desiged to manage a Debian Server that hosts the Fulcrum project, with all of the dependencies and services included. 

class nebula::role::fulcrum::standalone (
# String $private_address_template = '192.168.0.%s',
# String $shibboleth_config_source = 'puppet:///shibboleth-fulcrum',
# Hash $hosts = {}
) {

  include nebula::role::minimum
  include nebula::profile::ruby
  include nebula::profile::fulcrum::base
  include nebula::profile::fulcrum::hosts
  include nebula::profile::fulcrum::app
  include nebula::profile::fulcrum::logrotate
  include nebula::profile::fulcrum::redis
# include nebula::profile::fulcrum::solr
# include nebula::profile::fulcrum::mysql

  # The perl profile is needed for monitor_pl to work, but it pulls in a
  # ton of stuff. We should probably allow for different haproxy http checks
  # for a service, and eliminate the perl/monitor_pl dependency here.
  include nebula::profile::www_lib::perl

# create_resources('host',$hosts)

# include nebula::profile::www_lib::apache::base
# include nebula::profile::www_lib::apache::fulcrum

# class { 'nebula::profile::shibboleth':
#   config_source    => $shibboleth_config_source,
#   watchdog_minutes => '*/30',
# }

# cron {
#   default:
#     user => 'root',
#   ;

#   'purge apache access logs 1/2':
#     hour    => 1,
#     minute  => 7,
#     command => '/usr/bin/find /var/log/apache2 -type f -mtime +14 -name "*log*" -exec /bin/rm {} \; > /dev/null 2>&1',
#   ;

#   'purge apache access logs 2/2':
#     hour    => 1,
#     minute  => 17,
#     command => '/usr/bin/find /var/log/apache2 -type f -mtime +2  -name "*log*" ! -name "*log*gz" -exec /usr/bin/pigz {} \; > /dev/null 2>&1',
#     require => Package['pigz'],
#   ;
# }

# ensure_packages(['pigz'])

# include nebula::profile::fulcrum::shibboleth
# include nebula::profile::fulcrum::fedora
}
