# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::ezproxy::ssl_key
#
# Update SSL certificate, key and chain automatically
#
# @example
#   include nebula::profile::ezproxy:ssl_key
class nebula::profile::ezproxy::ssl_key (
  String $ezproxy_dir  = '/l/local/ezproxy/var',
  String $sslcert_dir  = '/etc/ssl/certs',
  String $sslkey_dir   = '/etc/ssl/private',
  String  $ssl_cn      = 'proxy.lib.umich.edu',
  Integer $cert_id     = 11,
  String $service_name = 'ezproxy',
) {
  $ssl_dir     = "${ezproxy_dir}/ssl"
  $cert_prefix = sprintf('%08d', $cert_id) # Format integer as zero-padded 8 digits (e.g. 00000003)

  # Ensure SSL cert directory Exists
  file { $ssl_dir:
    ensure => directory,
    owner  => 'ezproxy',
    group  => 'ezproxy',
    mode   => '0700',
  }

  # Copy SSL cert and key into location
  file { "${sslcert_dir}/${ssl_cn}.crt":
    mode   => '0640',
    owner  => 'nobody',
    group  => 'ezproxy',
    source => "puppet:///ssl-certs/${ssl_cn}.crt"
  }

  #Need to figure out how to get puppet to recognize the chain.
  file { "${sslcert_dir}/chain.pem":
    mode   => '0640',
    owner  => 'nobody',
    group  => 'ezproxy',
    source => 'puppet:///ssl-certs/chain.crt'
  }

  file { "${sslkey_dir}/${ssl_cn}.key":
    mode   => '0640',
    owner  => 'nobody',
    group  => 'ezproxy',
    source => "puppet:///ssl-certs/${ssl_cn}.key"
  }

  # Create symlink to ssl cert 
  file { "${ssl_dir}/${cert_prefix}.crt":
    ensure  => link,
    target  => "${sslcert_dir}/${ssl_cn}.crt",
    require => File[$ssl_dir],
    notify  => Service[$service_name],
  }

  # Create symlink to ssl key
  file { "${ssl_dir}/${cert_prefix}.key":
    ensure  => link,
    target  => "${sslkey_dir}/${ssl_cn}.key",
    require => File[$ssl_dir],
    notify  => Service[$service_name],
  }

  # Create symlink to intermediate chain
  file { "${ssl_dir}/${cert_prefix}.ca":
    ensure  => link,
    target  => "${sslcert_dir}/chain.pem",
    require => File[$ssl_dir],
    notify  => Service[$service_name],
  }

  # Update active file and set contents to match current certificate 
  file { "${ssl_dir}/active":
    ensure  => file,
    owner   => 'ezproxy',
    group   => 'ezproxy',
    mode    => '0644',
    content => "${cert_id}\n",
    require => File[$ssl_dir],
    notify  => Service[$service_name],
  }

  # notfiy ezpoxy and restart service
  service { $service_name:
    ensure => running,
    enable => true,
  }
}
