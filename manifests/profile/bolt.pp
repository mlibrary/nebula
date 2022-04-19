# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::bolt {
  package { 'puppet-bolt': }

  $users = lookup('nebula::profile::authorized_keys::ssh_keys').keys
  $membership = inverted_hashlist('nebula::usergroup::membership')

  $users.each |$user| {
    $data = $membership[$user]

    user { $user:
      ensure  => 'present',
      gid     => 100,
      shell   => '/bin/bash',
      home    => "/home/${user}",
      comment => $data['comment'],
      uid     => $data['uid'],
      require => File["/home/${user}"],
    }

    file { "/home/${user}":
      ensure => 'directory',
      owner  => $data['uid'],
      group  => 100,
      mode   => '0755',
    }
  }
}
