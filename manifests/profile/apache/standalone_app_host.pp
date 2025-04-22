# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::standalone_app_host
#
# Provides apache for nebula::role::app_host::standalone
#
# @example
#   include nebula::profile::apache::standalone_app_host

class nebula::profile::apache::standalone_app_host (
  $ssl_cn = $::networking['fqdn']
) {
  class { 'nebula::profile::ssl_keypair':
    common_name => $ssl_cn
  }

  file { '/etc/ssl/chain':
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    links   => 'manage',
    source  => 'puppet:///ssl-certs/chain'
  }

  @nebula::taghosts::tag { 'apache': }
  class { 'apache':
    default_mods      => false,
    default_vhost     => false,
    default_ssl_vhost => false,
    purge_vhost_dir   => false,
    conf_enabled      => '/etc/apache2/conf-enabled',
  }

  apache::mod { 'access_compat': }
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::headers
  include apache::mod::rewrite
  include apache::mod::setenvif

  class { 'apache::mod::ssl':
    ssl_protocol         => '-all +TLSv1.3',
    ssl_openssl_conf_cmd => 'Curves X25519:prime256v1:secp384r1',
    ssl_honorcipherorder => false
  }

  apache::listen { ['80','443']: }
}
