
# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::ingest_service
#
# Manage the ingest systemd service for hathitrust
#
# @example
#   include nebula::profile::hathitrust::ingest_service
class nebula::profile::hathitrust::ingest_service(
  String $config
) {
    file { '/etc/systemd/system/feedd.service':
    ensure  => 'present',
    content => template('nebula/profile/hathitrust/ingest_service/feedd.service.erb'),
    notify  => Service['feedd']
  }

  service { 'feedd':
    # no ensure -- puppet should enable it but otherwise leave it the way it
    # found it, since it starts & stops on a schedule (below)
    enable     => true,
    hasrestart => true
  }
}
