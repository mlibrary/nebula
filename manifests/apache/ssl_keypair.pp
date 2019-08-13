# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::ssl_keypair (
  String $chain_crt,
) {
  $ssl_cert = "/etc/ssl/certs/${title}.crt"
  $ssl_key = "/etc/ssl/private/${title}.key"
  $ssl_chain = "/etc/ssl/certs/${chain_crt}"

  file { $ssl_cert:
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${title}.crt"
  }

  ensure_resource('file', $ssl_chain, {
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${chain_crt}"
  })

  file { $ssl_key:
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${title}.key"
  }

  Apache::Vhost <| tag == "ssl-${title}" |> {
    ssl          => true,
    ssl_protocol => '+TLSv1.2',
    ssl_cipher   => 'ECDHE-RSA-AES256-GCM-SHA384',
    ssl_cert     => "/etc/ssl/certs/${title}.crt",
    ssl_key      => "/etc/ssl/private/${title}.key",
    ssl_chain    => "/etc/ssl/certs/${chain_crt}"
  }
}
