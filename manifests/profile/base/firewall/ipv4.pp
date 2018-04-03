# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::firewall::ipv4
#
# Set up the firewall based on hieradata.
#
# @param filename Path to firewall
# @param rules Rules to add to firewall
#
# @example
#   include nebula::profile::base::firewall::ipv4
class nebula::profile::base::firewall::ipv4 (
  String $filename,
  Array  $rules,
) {
  package { 'iptables-persistent': }

  service { 'netfilter-persistent':
    require    => Package['iptables-persistent'],
    hasrestart => true,
  }

  nebula::file::firewall { $filename:
    rules   => $rules,
    require => Package['iptables-persistent'],
    notify  => Service['netfilter-persistent'],
  }
}
