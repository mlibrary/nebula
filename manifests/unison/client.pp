# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

define nebula::unison::client (
  String $server,
  Integer $port,
  String $root,
  Array[String] $paths,
  Array[String] $filesystems,
  String $home = '/root',
  Integer $watchdog_sec = 7200,
  Optional[Array[String]] $ignores = undef,
) {

  include nebula::profile::unison::client

  $remote_root = "socket://${server}:${port}${root}"

  file { "${home}/.unison/${title}.prf":
    content => template('nebula/unison/client/prefs.erb'),
    notify  => "Service[unison-client-${title}]"
  }

  file { "/etc/systemd/system/unison-client-${title}.service":
    content => template('nebula/unison/client/service.erb'),
    notify  => "Service[unison-client-${title}]"
  }

  service { "unison-client-${title}":
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    require    => Package[unison]
  }

  @@firewall { "200 Unison: ${title} ${::hostname}":
    proto  => 'tcp',
    dport  => [$port],
    source => $::ipaddress,
    state  => 'NEW',
    jump   => 'accept',
    tag    =>  "unison-client-${title}"
  }

}
