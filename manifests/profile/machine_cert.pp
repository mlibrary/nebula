# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::machine_cert
#
# Manage a combined cert + key pem file to use as a client certificate.
#
# Take the puppet-issued certificate and combine into conventional Debian
# directory (/etc/ssl/private), using the machine name as the filename base
# and giving it a .pem extension.
#
# @example
#   include nebula::profile::machine_cert
class nebula::profile::machine_cert (
  String $certname = $trusted['certname'],
  String $client_cert = "/etc/ssl/private/${certname}.pem"
) {
  concat { $client_cert:
    ensure => 'present',
    mode   => '0600',
    owner  => 'root',
  }

  concat::fragment { 'client cert':
    target => $client_cert,
    source => "/etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    order  =>  1
  }

  concat::fragment { 'client key':
    target => $client_cert,
    source => "/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    order  =>  2
  }
}
