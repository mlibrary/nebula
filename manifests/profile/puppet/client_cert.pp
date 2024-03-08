# nebula::profile::puppet::client_cert
#
# Generate pem from puppet agent cert, so we can use it as a client cert
#
# @example
#   include nebula::profile::puppet::client_cert
#
class nebula::profile::puppet::client_cert () {
  $certname = $trusted['certname'];
  $client_cert = "/etc/ssl/private/${certname}.pem";

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
