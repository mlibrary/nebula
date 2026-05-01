# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Profile for a server running the Combine metadata harvester
class nebula::profile::combine (
  String $server_name = $::networking['fqdn'],
) {
  include nebula::profile::https_to_port

  $letsencrypt_directory = $facts['letsencrypt_directory'][$server_name]

  if $letsencrypt_directory {
    # Only serve the HTTPS site if the cert already exists.
    Nginx::Resource::Server <| title == 'https-forwarder' |> {
      proxy_read_timeout    => '900s',
      proxy_connect_timeout => '900s',
      proxy_send_timeout    => '900s',
    }
  }

  file { '/etc/sysctl.d/combine.conf':
    content => template('nebula/profile/combine/sysctl.conf.erb'),
  }
}

