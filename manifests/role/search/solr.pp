# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::role::search::solr {
  include nebula::role::minimum

  include nebula::profile::ntp
  include nebula::profile::unattended_upgrades
  include nebula::profile::kubernetes::dns_client

  include nebula::profile::interactive
  include nebula::profile::search::catalog::solr
  include nebula::profile::search::catalog::solr_monitor

  case $facts['os']['distro']['codename'] {
    'bullseye': {
      include nebula::profile::openjdk_java
    }

    default: {
      include nebula::profile::search::openjdk_java
    }
  }

  # These three are effectively the requirements for getting user login
  # with kerberos and duo.
  include nebula::profile::duo
  include nebula::profile::krb5
  include nebula::profile::networking
}
