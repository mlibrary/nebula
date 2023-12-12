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

  exec { "create bolt github ssh keypair":
    creates => "/var/local/bolt_repo_key/id_ecdsa",
    user    => "nobody",
    command => "/usr/bin/ssh-keygen -t ecdsa -N '' -C '${::hostname}' -f /var/local/bolt_repo_key/id_ecdsa",
    require => File["/var/local/bolt_repo_key"],
  }

  # do this if needed; don't just assume
  #exec { "create /var/local/github-ssh-keys":
  #  creates => "/var/local/github-ssh-keys",
  #  command => "/usr/bin/ssh-keyscan github.com > /var/local/github-ssh-keys",
  #}

  #concat_fragment { "github ssh keys":
  #}

  file { "/var/local/bolt_repo_key":
    ensure => "directory",
    owner  => "nobody",
    group  => "nobody",
    mode   => "0700",
  }

  file { "/opt/bolt":
    ensure => "directory",
    owner  => "nobody",
    group  => "nobody",
    mode   => "0755",
  }

  vcsrepo { "/opt/bolt":
    provider => "git",
    ensure   => "latest",
    source   => "ssh://git@github.com/mlibrary/bolt.git",
    user     => "nobody",
    identity => "/var/local/bolt_repo_key/id_ecdsa",
    require  => [
      Exec["create bolt github ssh keypair"],
      File["/opt/bolt"],
    ]
  }
}
