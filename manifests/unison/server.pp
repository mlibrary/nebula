# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::unison::server (
  String  $root,
  Array[String] $paths,
  Array[String] $filesystems,
  String $home = '/root',
  Integer $port = 2647,
  Optional[Array[String]] $ignores = undef,
) {
  ensure_packages(['unison'])

  file { "/etc/systemd/system/unison-${title}.service":
    content => template('nebula/unison/server/service.erb'),
    notify  => "Service[unison-${title}]"
  }

  service { "unison-${title}":
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
    ignores     => $ignores,
    filesystems => $filesystems
  }

  Firewall <<| tag == "unison-client-${title}" |>>

}
