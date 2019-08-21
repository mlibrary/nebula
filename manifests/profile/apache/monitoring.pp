# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::monitoring
#
# Configure an endpoint for monitoring apache & dependencies by haproxy
# Note that it does not install monitor.pl and its configuration: that is done
# by nebula::profile::monitor.pl
#
# Variables:
#
# $location: A location that can be added to an apache::vhost directories array
# $scriptalias: A scriptalias that can be added to an apache::vhost aliases array
#
# @example
#   include nebula::profile::apache::monitoring

class nebula::profile::apache::monitoring (
  String $cgi_dir = '/usr/local/lib/cgi-bin',
  String $monitor_uri = '/monitor',
  String $monitor_dir = "${cgi_dir}/monitor",
) {

  $location = {
    provider => 'location',
    path     => $monitor_uri,
    require  => {
      enforce  => 'any',
      requires => [ 'local' ] + $nebula::profile::apache::haproxy_ips.map |String $ip| { "ip ${ip}" }
    }
  }

  $scriptalias = {
    scriptalias => $monitor_uri,
    path        => $monitor_dir
  }

  include apache::mod::cgi

  file { $cgi_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

}
