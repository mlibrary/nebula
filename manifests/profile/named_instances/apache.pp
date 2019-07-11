# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::named_instances::apache
#
# Configure Apache to serve applications via mod_proxy
# This does not configure any virtual hosts.
#
# @example
#   include nebula::profile::named_instances::apache

class nebula::profile::named_instances::apache (
  $ssl_cn = $::fqdn
) {

  class { 'nebula::profile::ssl_keypair':
    common_name => $ssl_cn
  }

  class { 'apache':
    default_mods      => false,
    default_vhost     => false,
    default_ssl_vhost => false,
    purge_vhost_dir   => false
  }

  apache::mod { 'access_compat': }
  # apache::mod { 'authz_host': }
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::headers
  include apache::mod::ssl
  include apache::mod::rewrite
  include apache::mod::setenvif

  apache::mod { 'cosign':
    package => 'libapache2-mod-cosign'
  }

  apache::listen { ['80','443']: }

  include nebula::profile::networking::firewall::http_datacenters

}
