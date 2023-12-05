# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::standalone_app_host
#
# Configure Apache to serve applications via mod_proxy
# This does not configure any virtual hosts.
#
# @example
#   include nebula::profile::apache::standalone_app_host

class nebula::profile::apache::standalone_app_host (
) {

  class { 'apache':
    default_mods      => false,
    default_vhost     => false,
    default_ssl_vhost => false,
    purge_vhost_dir   => false,
    conf_enabled      => '/etc/apache2/conf-enabled',
  }

}

