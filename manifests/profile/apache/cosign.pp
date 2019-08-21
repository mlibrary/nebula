# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::apache::cosign
#
# Configures cosign forapache
#
# @example
#   include nebula::profile::apache::cosign

class nebula::profile::apache::cosign () {

  apache::mod { 'cosign':
    package       => 'libapache2-mod-cosign',
  }

  file { '/var/cosign/filter':
    ensure => 'directory',
    owner  => 'nobody',
    group  => 'nogroup'
  }
}
