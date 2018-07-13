# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Load-balanced frontend
#
# @example
#   nebula::haproxy_service { 'namevar': }
define nebula::haproxy_service(
  String          $floating_ip,
  Array[String]   $node_names = [],
  String          $cert_source = ''
) {

  require nebula::profile::haproxy::prereqs

  $service = $title

  file { "/etc/haproxy/${service}.cfg":
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/service.cfg.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy'],
  }

  if $cert_source != '' {
    file { "/etc/ssl/private/${service}":
      ensure  => 'directory',
      mode    => '0700',
      owner   => 'haproxy',
      group   => 'haproxy',
      recurse => true,
      purge   => true,
      links   => 'follow',
      notify  => Service['haproxy'],
      source  => "puppet://${cert_source}/${service}"
    }
  }
}
