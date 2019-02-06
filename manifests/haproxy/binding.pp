# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Load-balanced frontend
#
# @example
#   nebula::haproxy::binding { 'namevar': }
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

  # TODO - handle case where https_offload = false - ie proxy https to server

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
