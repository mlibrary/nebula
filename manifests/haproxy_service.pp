# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Load-balanced frontend
#
# @example
#   nebula::haproxy_service { 'namevar': }
define nebula::haproxy_service(
  String           $floating_ip,
  Array[String]    $node_names = [],
  Optional[String] $cert_source = undef,
  Optional[String] $throttle_condition = undef,
  Integer          $max_requests_per_sec = 0,
  Integer          $max_requests_burst = 0,
  Hash             $whitelists = {}
) {

  include nebula::profile::haproxy::prereqs

  $service = $title

  if $max_requests_per_sec > 0 {
    file { "/etc/haproxy/errors/${service}509.http":
      ensure => 'present',
      mode   => '0644',
      notify => Service['haproxy'],
      source => "puppet:///errorfiles/${service}509.http"
    }
  }

  $whitelists.each |String $whitelist, Array[String] $exemptions| {
    if $exemptions.size() > 0 {
      file { "/etc/haproxy/${service}_whitelist_${whitelist}.txt":
        ensure  => 'present',
        mode    => '0644',
        notify  => Service['haproxy'],
        content => $exemptions.map |$exemption| { "${exemption}\n" }.join('')
      }
    }
  }

  file { "/etc/haproxy/services.d/${service}.cfg":
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/haproxy/service.cfg.erb'),
    notify  => Service['haproxy'],
  }

  if $cert_source {
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
