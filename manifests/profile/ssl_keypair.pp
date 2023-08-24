# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::ssl_keypair
#
# Installs an ssl keypair with an intermediate cert for use by Apache
#
# @example
#   include nebula::profile::ssl_keypair
class nebula::profile::ssl_keypair (
  String $common_name,
) {
  $ssl_cert = "/etc/ssl/certs/${common_name}.crt"
  $ssl_key = "/etc/ssl/private/${common_name}.key"

  file { $ssl_cert:
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${common_name}.crt"
  }

  file { $ssl_key:
    mode   => '0600',
    owner  => 'root',
    group  => 'root',
    notify => Class['Apache::Service'],
    source => "puppet:///ssl-certs/${common_name}.key"
  }
}
