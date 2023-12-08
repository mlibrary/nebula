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
) {

  class { 'apache':
    default_mods      => false,
    default_vhost     => false,
    default_ssl_vhost => false,
    purge_vhost_dir   => false,
    conf_enabled      => '/etc/apache2/conf-enabled',
  }

}

