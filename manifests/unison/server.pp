# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::unison::server (
  String  $root,
  Array[String] $paths,
  Array[String] $filesystems,
  Integer $port = 2647
) {
  include nebula::profile::unison::server

  file { "/etc/systemd/system/unison@${title}.service.d":
    ensure => 'directory'
  }

  file { "/etc/systemd/system/unison@${title}.service.d/drop-in.conf":
    content => template('nebula/unison/server/drop-in.conf.erb'),
    notify  => "Service[unison@${title}]"
  }

  service { "unison@${title}":
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package[unison]
  }

  @@nebula::unison::client { $title:
    server      => $::fqdn,
    port        => $port,
    root        => $root,
    paths       => $paths,
    filesystems => $filesystems
  }

  Firewall <<| tag == "unison-client-${title}" |>>

}
