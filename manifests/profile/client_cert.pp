# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::client_cert
#
# Put a copy of the certificate this host uses to talk to the
# puppetserver where apache can see it. This way, the host will be able
# to verify its authenticity with anyone that trusts our puppet CA.
#
# @example Including the profile
#   include nebula::profile::client_cert
#
# @example Adding the certificate to an apache vhost
#   ssl_proxy_machine_cert => $nebula::profile::client_cert::path,
class nebula::profile::client_cert {
  $certname = $trusted['certname'];
  $path = "/etc/ssl/private/${certname}.pem";

  concat { $path:
    ensure => 'present',
    mode   => '0600',
    owner  => 'root',
  }

  concat::fragment { "${path} cert":
    target => $path,
    source => "/etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    order  =>  1
  }

  concat::fragment { "${path} key":
    target => $path,
    source => "/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    order  =>  2
  }
}
