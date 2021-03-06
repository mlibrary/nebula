# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Prometheus node exporter
#
# Every node we want metrics on needs a node exporter installed, and
# it's best if they all have the same version of the exporter even if
# they're on different OS versions. So we maintain our own deb and
# maintain all configuration through puppet.
#
# Each node exports some service discovery lines to a scraper in the
# same datacenter if it can. It also opens port 9100 to that same
# scraper. If there isn't a dedicated scraper for this node's
# datacenter, then it'll default to a specified scraper elsewhere.
#
# @param version Optional version of the node exporter to install
# @param covered_datacenters A list of datacenters that have dedicated
#   Prometheus scrapers.
# @param default_datacenter If this node is in a datacenter that isn't
#   in the covered_datacenters list, it will be scraped by the scraper
#   in this datacenter instead.
class nebula::profile::prometheus::exporter::node (
  Optional[String] $version = undef,
  Array $covered_datacenters = [],
  String $default_datacenter = 'default',
) {
  $log_file = '/var/log/prometheus-node-exporter.log'

  include nebula::virtual::users
  include nebula::profile::groups
  include nebula::subscriber::rsyslog
  include nebula::subscriber::systemctl_daemon_reload

  # There's a bug in HP machines that only affects pre-stretch that
  # makes hwmon checks spew a bunch of annoying log messages. This can
  # be removed (as well as the corresponding logic in the template) once
  # we don't have jessie machines anymore.
  #
  # For more info, http://www.serveradminblog.com/2015/05/kernel-acpi-error-smbusipmigenericserialbus/
  if $facts {
    if $facts['os'] and $facts['dmi'] {
      if $facts['os']['distro'] and $facts['dmi']['manufacturer'] {
        if $facts['os']['distro']['codename'] {
          if $facts['os']['distro']['codename'] == 'jessie' and $facts['dmi']['manufacturer'] == 'HP' {
            $disable_hwmon = true
          } else {
            $disable_hwmon = false
          }
        }
      }
    }
  }

  file { '/etc/default/prometheus-node-exporter':
    content => template('nebula/profile/prometheus/exporter/node/defaults.sh.erb'),
    notify  => Service['prometheus-node-exporter'],
    require => Package['prometheus-node-exporter'],
  }

  file { '/etc/systemd/system/prometheus-node-exporter.service':
    content => template('nebula/profile/prometheus/exporter/node/systemd.ini.erb'),
    notify  => [Service['prometheus-node-exporter'], Exec['systemctl daemon-reload']],
    require => Package['prometheus-node-exporter'],
  }

  file { '/etc/rsyslog.d/prometheus-node-exporter.conf':
    content => template('nebula/profile/prometheus/exporter/node/rsyslog.conf.erb'),
    notify  => Service['prometheus-node-exporter', 'rsyslog'],
  }

  $prometheus_errors_total = $::prometheus_errors_total
  file { '/var/lib/prometheus/node-exporter/node_exporter_errors.prom':
    content => template('nebula/profile/prometheus/exporter/node/node_exporter_errors.prom.erb'),
  }

  file { '/etc/cron.daily/check-reboot':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('nebula/profile/prometheus/exporter/node/check_reboot.sh.erb'),
  }

  file { $log_file:
    owner   => 'root',
    group   => 'adm',
    mode    => '0640',
    content => '',
  }

  service { 'prometheus-node-exporter':
    ensure => 'running',
    enable => true,
  }

  package { 'prometheus-node-exporter':
    ensure  => pick($version, 'installed'),
    require => [User['prometheus'], File['/var/lib/prometheus/node-exporter']],
  }

  file { '/var/lib/prometheus/node-exporter':
    ensure => 'directory',
    mode   => '2775',
    owner  => 'prometheus',
    group  => 'prometheus',
  }

  file { '/var/lib/prometheus':
    ensure => 'directory',
    mode   => '2775',
    owner  => 'prometheus',
    group  => 'prometheus',
  }

  realize User['prometheus']

  $role = lookup_role()
  $ipaddress = $::ipaddress
  $datacenter = $::datacenter
  $hostname = $::hostname

  if $datacenter in $covered_datacenters {
    $monitoring_datacenter = $datacenter
  } else {
    $monitoring_datacenter = $default_datacenter
  }

  ensure_packages(['curl'])

  concat_file { '/usr/local/bin/pushgateway':
    mode => '0755',
  }

  concat_fragment { '01 pushgateway shebang':
    target  => '/usr/local/bin/pushgateway',
    content => "#!/usr/bin/env bash\n",
  }

  Concat_fragment <<| title == "02 pushgateway url ${monitoring_datacenter}" |>>

  concat_fragment { '03 main pushgateway content':
    target  => '/usr/local/bin/pushgateway',
    content => template('nebula/profile/prometheus/exporter/node/pushgateway.sh.erb'),
  }

  @@concat_fragment { "prometheus node service ${hostname}":
    tag     => "${monitoring_datacenter}_prometheus_node_service_list",
    target  => '/etc/prometheus/nodes.yml',
    content => template('nebula/profile/prometheus/exporter/node/target.yaml.erb'),
  }

  @@firewall { "300 pushgateway ${::hostname}":
    tag    => "${monitoring_datacenter}_pushgateway_node",
    proto  => 'tcp',
    dport  => 9091,
    source => $::ipaddress,
    state  => 'NEW',
    action => 'accept',
  }

  if $::lsbdistcodename != 'jessie' {
    Firewall <<| tag == "${monitoring_datacenter}_prometheus_node_exporter" |>>
  }
}
