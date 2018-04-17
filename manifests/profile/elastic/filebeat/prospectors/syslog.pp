# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include nebula::profile::elastic::filebeat::prospectors::syslog
class nebula::profile::elastic::filebeat::prospectors::syslog {
  include nebula::profile::elastic::filebeat

  file { '/etc/filebeat/prospectors/syslog.yml':
    content => template('nebula/profile/elastic/filebeat/prospectors/syslog.yml.erb'),
    notify  => Service['filebeat'],
  }
}
