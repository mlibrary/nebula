# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::role::app_host::quod_prod
#
# Application host (QUOD production)
#
# @example
#   include nebula::role::app_host::quod_prod
class nebula::role::app_host::quod_prod {
  include nebula::role::umich
  include nebula::profile::krb5
  include nebula::profile::afs
  include nebula::profile::users
  include nebula::profile::tsm
  include nebula::profile::quod::prod::perl
  include nebula::profile::quod::prod::haproxy
  include nebula::profile::networking::firewall::http

  # We put the machine certificate in a statically named file because the rdist
  # config is static and it would be more difficult to refer it by hostname.
  class { 'nebula::profile::machine_cert':
    client_cert => '/etc/ssl/private/machine-cert-quod.lib.pem',
  }
}
