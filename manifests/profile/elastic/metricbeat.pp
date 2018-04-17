# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Metricbeat
#
# Install and configure metricbeat, and ensure that its service is
# running.
#
# @param logstash_auth_cert If (and only if) defined as a 'puppet://'
#   path, logstash will use the source file as its ssl certificate
#   authority. Otherwise, logstash output won't use SSL.
# @param logstash_hosts Logstash host IP addresses
# @param period System module period in seconds
#
# @example
#   include nebula::profile::elastic::metricbeat
class nebula::profile::elastic::metricbeat (
  String  $logstash_auth_cert = lookup('nebula::profile::elastic::logstash_auth_cert'),
  Array   $logstash_hosts = lookup('nebula::profile::elastic::logstash_hosts'),
  Integer $period = lookup('nebula::profile::elastic::period'),
) {
  include nebula::profile::elastic

  service { 'metricbeat':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/metricbeat/metricbeat.yml':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/elastic/metricbeat.yml.erb'),
    require => Package['metricbeat'],
    notify  => Service['metricbeat'],
  }

  package { 'metricbeat': }
}
