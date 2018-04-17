# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# Filebeat
#
# @example
#   include nebula::profile::elastic::filebeat
class nebula::profile::elastic::filebeat {
  require nebula::profile::elastic

  service { 'filebeat':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/filebeat/filebeat.yml':
    ensure  => 'present',
    mode    => '0644',
    content => template('nebula/profile/elastic/filebeat.yml.erb'),
    require => Package['filebeat'],
    notify  => Service['filebeat'],
  }

  file { '/etc/filebeat/prospectors':
    ensure  => 'directory',
    require => Package['filebeat'],
  }

  package { 'filebeat': }
}
