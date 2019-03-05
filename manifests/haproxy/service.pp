# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# A set of front-ends and back-ends for haproxy corresponding to a route 53
# record set that resolves to HAproxy. Typically this is a set of web sites
# running on a particular set of servers -- for example www-lib or hathitrust.
#
# These services are defined in hiera under nebula::profile::haproxy::services
# and declared as virtual resources in nebula::profile::haproxy. They are
# realized in the node to haproxy bindings, so that configuration is only
# materialized for any services where at least one web server node is bound to
# it on a particular haproxy node.
#
# @param floating_ip The ip address to listen on; this will be shared via
#   keepalived with any other haproxy instances at the same datacenter.
#
# @param cert_source The source  (relative to puppet://) where the SSL certs
#   for this service can be found
#
# @param throttle_condition Only throttle requests if they meet this haproxy
#   condition
#
# @param max_requests_per_sec Allow this many requests per second on average
#
# @param max_requests_burst Allow exceeding max_requests_per_sec on average
#   until hitting this many requests
#
# @param whitelists A set of whitelists to use for exempting requests from
#   throttling. The keys are any haproxy sample fetch derivative that can be used
#   in a whitelist, and the values are arrays of patterns to match using the
#   haproxy "acl -f" functionality; see
#   https://cbonte.github.io/haproxy-dconv/1.7/configuration.html#7
#
# @example
#   nebula::haproxy::service { 'www-whatever':
#     floating_ip          => '1.2.3.4'
#     cert_source          => '/ssl-certs/haproxy',
#     throttle_condition   => 'path_beg /should_be_throttled',
#     max_requests_per_sec => '4',
#     max_requests_burst   => '200',
#     whitelists           => {
#       path_beg           => ['/dont_throttle_this','/or_this'],
#       path_sub           => ['in_the_middle'],
#       path_end           => ['.css','.js'],
#       src                => ['5.6.7.0/24','8.9.10.11']]
#     }
#  }
define nebula::haproxy::service(
  String           $floating_ip,
  Optional[String] $cert_source = undef,
  Optional[String] $throttle_condition = undef,
  Integer          $max_requests_per_sec = 0,
  Integer          $max_requests_burst = 0,
  Hash             $whitelists = {}
) {

  include nebula::profile::haproxy::prereqs

  $service = $title
  $http_files = lookup('nebula::http_files')
  $nonempty_whitelists = $whitelists.filter |$whitelist,$exemptions| { $exemptions.length > 0 }

  if $max_requests_per_sec > 0 {
    file { "/etc/haproxy/errors/${service}509.http":
      ensure => 'present',
      mode   => '0644',
      notify => Service['haproxy'],
      source => "https://${http_files}/errorfiles/${service}509.http"
    }
  }

  $nonempty_whitelists.each |String $whitelist, Array[String] $exemptions| {
    file { "/etc/haproxy/${service}_whitelist_${whitelist}.txt":
      ensure  => 'present',
      mode    => '0644',
      notify  => Service['haproxy'],
      content => $exemptions.map |$exemption| { "${exemption}\n" }.join('')
    }
  }

  $protocols = {
    http  => { port => 80, ssl => '' },
    https => { port => 443, ssl => " ssl crt /etc/ssl/private/${service}" }
  }

  $protocols.each |$protocol,$protocol_options| {
    $service_cfg = "/etc/haproxy/services.d/${service}-${protocol}.cfg"
    $service_loc = "${service}-${::datacenter}"
    $service_prefix = "${service_loc}-${protocol}"

    concat { $service_cfg:
      ensure => 'present',
      mode   => '0644',
      notify =>  Service['haproxy']
    }

    concat_fragment { "${service_prefix} backend":
      target  => $service_cfg,
      content => "backend ${service_prefix}-back\n",
      order   => '01'
    }

    if($protocol == 'https') {
      concat_fragment { "${service_prefix} check":
        target  => $service_cfg,
        content => "http-check expect status 200\n",
        order   => '02'
      }
    }

    # throttling
    if($max_requests_burst > 0 and $max_requests_per_sec > 0) {
      $duration = $max_requests_burst / $max_requests_per_sec

      concat_fragment { "${service_prefix} throttling":
        target  => $service_cfg,
        content => template('nebula/profile/haproxy/throttling.erb'),
        order   => '03'
      }
    }

    Concat_fragment <| tag == "${service_prefix}_binding" |>

    if $nonempty_whitelists.length > 0 or $throttle_condition {
      concat_fragment { "${service_prefix} back-exempt":
        target  => $service_cfg,
        content => "backend ${service_prefix}-back-exempt\n",
        order   => '05'
      }

      Concat_fragment <| tag == "${service_prefix}_exempt_binding" |>
    }


    concat_fragment { "${service_prefix} frontend":
      target  => $service_cfg,
      content => template('nebula/profile/haproxy/frontend.erb'),
      order   => '07'
    }

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
      source  => "puppet://${cert_source}/${service}",
      # Package['haproxy'] provides the haproxy user
      require => Package['haproxy']
    }
  }

}
