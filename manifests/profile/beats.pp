# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# beats
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
#   include nebula::profile::beats
class nebula::profile::beats (
  String  $logstash_auth_cert,
  Array   $logstash_hosts,
  Integer $period,
) {
  service { 'metricbeat':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => File['/etc/metricbeat/metricbeat.yml'],
  }

  service { 'filebeat':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    # require    => File['/etc/metricbeat/metricbeat.yml'],
  }

  file { '/etc/metricbeat/metricbeat.yml':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/beats/metricbeat.yml.erb'),
    require => Package['metricbeat'],
  }

  file { '/etc/filebeat/filebeat.yml':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/beats/filebeat.yml.erb'),
    require => Package['filebeat'],
  }

  file { '/etc/filebeat/prospectors':
    ensure  => 'directory',
    require => Package['filebeat'],
  }

  package { 'metricbeat':
    require => Apt::Source['elastic.co'],
  }

  package { 'filebeat':
    require => Apt::Source['elastic.co'],
  }

  apt::source { 'elastic.co':
    comment  => 'Elastic.co apt source for beats and elastic search',
    location => 'https://artifacts.elastic.co/packages/5.x/apt',
    release  => 'stable',
    repos    => 'main',
    key      => {
      'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
      'server' => 'keyserver.ubuntu.com',
    },
    include  => {
      'src' => false,
      'deb' => true,
    },
    require  => Package['apt-transport-https'],
  }

  if $logstash_auth_cert != '' {
    file { '/etc/ssl/certs/logstash-forwarder.crt':
      ensure  => 'present',
      mode    => '0644',
      source  => "puppet://${logstash_auth_cert}",
      require => File['/etc/ssl/certs'],
    }

    file { '/etc/ssl/certs':
      ensure => 'directory',
      mode   => '0755',
    }
  }

  package { 'apt-transport-https': }
}
