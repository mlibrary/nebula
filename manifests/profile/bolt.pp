# Copyright (c) 2022 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::bolt {
  include nebula::virtual::users
  package { 'puppet-bolt': }

  $users = lookup('nebula::profile::authorized_keys::ssh_keys').keys
  $all_users = lookup('nebula::virtual::users::all_users')

  $users.each |$user| {
    $data = $all_users[$user]

    User <| title == $user |> {
      home    => "/home/${user}",
      gid     => 100,
      require => File["/home/${user}"],
    }

    file { "/home/${user}":
      ensure => 'directory',
      owner  => $data['uid'],
      group  => 100,
      mode   => '0755',
    }
  }

  concat { '/etc/ssh/ssh_known_hosts': }
  Concat_fragment <<| tag == 'known_host_public_keys' |>>
}
