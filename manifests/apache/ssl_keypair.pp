# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::apache::ssl_keypair () {
  $ssl_cert = "${nebula::profile::apache::ssl_cert_dir}/${title}.crt"
  $ssl_key = "${nebula::profile::apache::ssl_key_dir}/${title}.key"

  file { $ssl_cert:
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${title}.crt"
  }

  file { $ssl_key:
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${title}.key"
  }

}
