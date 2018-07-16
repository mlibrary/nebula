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
  String          $cert_source = '',
  Integer         $max_requests_per_sec = 0,
  Integer         $max_requests_burst = 0,
  Array[String]   $exempt_paths = [],
  Array[String]   $exempt_suffixes = [],
  Array[String]   $exempt_ips = []
) {

  require nebula::profile::haproxy::prereqs

  $service = $title

  $whitelists = { 
    "path" => $exempt_paths,
    "suffix" => $exempt_suffixes,
    "ip" => $exempt_ips
  }

  $whitelists.each |String $whitelist, Array[String] $exemptions| {
    if $exemptions.size() > 0 {
      file { "/etc/haproxy/${service}_whitelist_${whitelist}.txt":
        ensure  => 'present',
        mode    => '0644',
        require => Package['haproxy'],
        notify  => Service['haproxy'],
        content => $exemptions.map |$exemption| { "$exemption\n" }.join('')
      }
    }
  }

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
