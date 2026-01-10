# Copyright (c) 2026 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::quod::prod::metrics
#
# Collect and export quod metrics based on Apache logs and running processes
#
# @example
#   include nebula::profile::quod::prod::metrics
class nebula::profile::quod::prod::metrics (
  $mtail_port = 3903,
) {
  ensure_packages([
    'mtail'
  ])

  $role = lookup_role()
  $hostname = $::networking['hostname']
  $datacenter = $facts['datacenter']

  $all_private_addresses = $facts["mlibrary_ip_addresses"]["private"]
  if $all_private_addresses == [] {
    fail('Host cannot be scraped without a private IP address')
  } else {
    $ipaddress = $all_private_addresses[0]

    Firewall <<| tag == "${facts['datacenter']}_prometheus_private_quod_exporter" |>> {
      dport => $mtail_port,
    }
  }

  @@concat_fragment { "prometheus quod scrape config ${hostname}":
    tag     => "${datacenter}_prometheus_quod_service_list",
    target  => '/etc/prometheus/quod.yml',
    order   => '02',
    content => template('nebula/profile/prometheus/exporter/quod/target.yaml.erb')
  }

  # The package installs a systemd service and defaults file
  service { 'mtail':
    ensure  => 'running',
    enable  => true,
    require => Package['mtail'],
  }

  file { '/etc/mtail/quod_apache.mtail':
    content => 'nebula/mtail/quod_apache.mtail',
    notify  => Service['mtail'],
  }

  file { '/etc/default/mtail':
    ensure  => 'file',
    notify  => Service['mtail'],
    content => @("MTAILCONF")
      PORT=${mtail_port}
      LOGS=/var/apache2/access.log
      | MTAILCONF
  }
}
