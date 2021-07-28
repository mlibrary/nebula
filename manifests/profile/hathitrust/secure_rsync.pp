# Copyright (c) 2021 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::hathitrust::secure_rsync
#
# Install rsync+stunnel for secure HTRC datasets access
#
# @example
#   include nebula::profile::hathitrust::secure_rsync

class nebula::profile::hathitrust::secure_rsync (
  Hash   $datasets,
  Array  $allowed_networks,
  String $log_path = '/var/log/secure-rsync',
  String $rsync_home = '/etc/secure-rsync',
  String $rsync_user = 'nobody',
  Integer $stunnel_port = 1873,
) {
  ensure_packages (
    [
      'rsync',
      'stunnel4'
    ]
  )

  file { [$log_path, $rsync_home]:
    ensure => 'directory',
  }

  file {
    default:
      owner   => 'root',
      group   => 'root',
      require => [
        Package['rsync'],
        Package['stunnel4'],
      ],
      notify  => Service[secure-rsync];
    '/etc/systemd/system/secure-rsync.service':
      content  => template('nebula/profile/hathitrust/secure_rsync/secure-rsync.service.erb');
    "${rsync_home}/stunnel.conf":
      content  => template('nebula/profile/hathitrust/secure_rsync/stunnel.conf.erb');
    "${rsync_home}/rsyncd.conf":
      content => template('nebula/profile/hathitrust/rsync/rsyncd.conf.erb');
    "${rsync_home}/server.key":
      source => 'puppet:///ssl-certs/self-signed/secure-rsync-server.key',
      mode   => '0600';
    "${rsync_home}/server.crt":
      source => 'puppet:///ssl-certs/self-signed/secure-rsync-server.crt';
    "${rsync_home}/client.crt":
      source => 'puppet:///ssl-certs/self-signed/secure-rsync-client.crt';
  }

  service { 'secure-rsync':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => [
      Package['rsync'],
      Package['stunnel4'],
    ]
  }

  $allowed_networks.flatten.each |$network| {
    firewall { "200 secure-rsync ${network['name']}":
      proto     => 'tcp',
      dport     => $stunnel_port,
      source    => $network['block'],
      src_range => $network['range'],
      state     => 'NEW',
      action    => 'accept',
    }
  }
}
