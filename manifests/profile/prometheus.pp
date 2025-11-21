# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::prometheus (
  Array $alert_managers = [],
  Array $static_wmi_nodes = [],
) {
  package { 'prometheus': }
  service { 'prometheus': }
  package { 'prometheus-pushgateway': }
  service { 'prometheus-pushgateway': }

  file { '/etc/prometheus/prometheus.yml':
    content => template('nebula/profile/prometheus/config.yml.erb'),
    notify  => Service['prometheus'],
  }
}
