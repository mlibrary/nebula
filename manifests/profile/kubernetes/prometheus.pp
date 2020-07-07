# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::kubernetes::prometheus {
  file { '/var/local/prometheus':
    ensure => 'directory',
  }

  concat_file { '/etc/prometheus/nodes.yml':
    path    => '/var/local/prometheus/nodes.yml',
    require => File['/var/local/prometheus'],
  }

  Concat_fragment <<| tag == "${::datacenter}_prometheus_node_service_list" |>>
}
