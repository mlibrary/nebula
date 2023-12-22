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

  user { "git":
    ensure     => "present",
    home       => "/var/lib/autogit",
    gid        => 100,
    managehome => true,
  }

  file { "/var/lib/autogit/.ssh":
    ensure  => "directory",
    owner   => "git",
    group   => 100,
    mode    => "0700",
    require => User["git"],
  }

  exec { "create /var/lib/autogit/.ssh/id_ecdsa":
    creates => "/var/lib/autogit/.ssh/id_ecdsa",
    user    => "git",
    command => "/usr/bin/ssh-keygen -t ecdsa -N '' -C '${::hostname}' -f /var/lib/autogit/.ssh/id_ecdsa",
    require => File["/var/lib/autogit/.ssh"],
  }

  exec { "create /var/local/github_ssh_keys":
    creates => "/var/local/github_ssh_keys",
    command => "/usr/bin/ssh-keyscan github.com > /var/local/github_ssh_keys",
  }

  concat_fragment { "github ssh keys":
    target  => "/etc/ssh/ssh_known_hosts",
    source  => "/var/local/github_ssh_keys",
    require => Exec["create /var/local/github_ssh_keys"],
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
      Exec["create /var/local/github_ssh_keys"],
      File["/opt/bolt"],
      Concat_fragment["github ssh keys"],
    ]
  }
}
