# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::rsync
#
# Install rsync for public-domain datasets access
#
# See example structure for datasets in spec/fixtures/hiera/hathitrust.yaml
# under nebula::profile::hathitrust::rsync::datasets
#
# @example
#   include nebula::profile::hathitrust::rsync

class nebula::profile::hathitrust::rsync (
  Hash $datasets,
  String $log_path = '/var/log/rsync',
  String $rsync_user = 'nobody',
) {
  ensure_packages (
    [
      'rsync'
    ]
  )

  file { $log_path:
    ensure => 'directory',
  }

  service { 'rsync':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package['rsync'],
  }

  file { '/etc/rsyncd.conf':
    require => Package[rsync],
    notify  => Service[rsync],
    content => template('nebula/profile/hathitrust/rsync/rsyncd.conf.erb')
  }

  $datasets.each |String $name, Hash $dataset| {
    $dataset['users'].each |Hash $user| {

      firewall { "200 rsync: dataset ${name} - ${user['comment']}":
        proto  => 'tcp',
        dport  => 873,
        source => $user['ip'],
        state  => 'NEW',
        action => 'accept'
      }
    }
  }

}
