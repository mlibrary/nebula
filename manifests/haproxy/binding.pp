# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Binds a server to a haproxy backend. Web server roles should export a
# nebula::haproxy::binding resource; nebula::profile::haproxy collects these
# resources and realizes the necessary concat fragments. The fragments are
# virtual so that the web server doesn't need to know whether or not exemptions
# from throttling are present. If they are, then two backends will be defined --
# one for throttled requests and one for non-throttled requests, and the web
# server needs to bind to both. If there is no throttling or no exemptions from
# throttling, then web servers only need to bind to a single (default) back
# end.
#
# @param service The prefix for the haproxy frontend & backend to use - for
# example www-lib or hathitrust - this corresponds to Route 53 record sets that
# resolve to haproxy.
#
# @param https_offload true if apache at ipaddress:443 speaks plain HTTP; false if it speaks HTTPS
# @param datacenter The datacenter of the node to bind to
# @param hostname The hostname of the node to bind to
# @param ipaddress The ip address HAproxy should use to reach the node
#
# @example
#   @@nebula::haproxy::binding { '${::hostname} myservice':
#     service       => 'myservice',
#     https_offload => 'false',
#     datacenter    => $::datacenter,
#     hostname      => $::hostname,
#     ipaddress     => $::ipaddress
#  }
define nebula::haproxy::binding(
  String $service,
  String $hostname,
  String $datacenter,
  String $ipaddress,
  Boolean $https_offload = true,
) {

  $last_octet = $ipaddress.split('\.')[-1]
  $cookie = "cookie s${last_octet}"
  $track = "track ${service}-${datacenter}-https-back/${hostname}"

  if($https_offload) {
    $ssl_opts = ''
  } else {
    $ssl_opts = ' ssl verify required ca-file /etc/ssl/certs/ca-certificates.crt'
  }

  @concat_fragment { "${service}-${datacenter}-http ${hostname} binding":
    target  => "/etc/haproxy/services.d/${service}-http.cfg",
    order   => '04',
    content => "server ${hostname} ${ipaddress}:80 ${track} ${cookie}\n",
    tag     => "${service}-${datacenter}-http_binding"
  }

  @concat_fragment { "${service}-${datacenter}-https ${hostname} binding":
    target  => "/etc/haproxy/services.d/${service}-https.cfg",
    order   => '04',
    content => "server ${hostname} ${ipaddress}:443${ssl_opts} check ${cookie}\n",
    tag     => "${service}-${datacenter}-https_binding"
  }

  @concat_fragment { "${service}-${datacenter}-http ${hostname} exempt binding":
    target  => "/etc/haproxy/services.d/${service}-http.cfg",
    order   => '06',
    content => "server ${hostname} ${ipaddress}:80 ${track} ${cookie}\n",
    tag     => "${service}-${datacenter}-http_exempt_binding"
  }

  @concat_fragment { "${service}-${datacenter}-https ${hostname} exempt binding":
    target  => "/etc/haproxy/services.d/${service}-https.cfg",
    order   => '06',
    content => "server ${hostname} ${ipaddress}:443${ssl_opts} ${track} ${cookie}\n",
    tag     => "${service}-${datacenter}-https_exempt_binding"
  }

  realize(Nebula::Haproxy::Service[$service])

}
