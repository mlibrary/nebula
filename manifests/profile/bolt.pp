# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::bolt {
  include nebula::profile::managed_known_hosts
  include nebula::profile::github_pull_account
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

  file { "/opt/bolt":
    ensure => "directory",
    owner  => "git",
    group  => 100,
    mode   => "0755",
  }

  vcsrepo { "/opt/bolt":
    provider => "git",
    ensure   => "latest",
    source   => "ssh://git@github.com/mlibrary/bolt.git",
    user     => "git",
    require  => [
      Class["nebula::profile::github_pull_account"],
      File["/opt/bolt"],
      Package["git"],
    ]
  }
}
