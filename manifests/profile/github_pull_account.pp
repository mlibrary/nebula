# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

class nebula::profile::github_pull_account (
  String $git_username = "git",
  Integer $git_gid = 100,
  String $git_homedir = "/var/lib/autogit",
) {
  package { "git": }

  user { $git_username:
    ensure     => "present",
    home       => $git_homedir,
    gid        => $git_gid,
    managehome => true,
  }

  file { "${git_homedir}/.ssh":
    ensure  => "directory",
    owner   => $git_username,
    group   => $git_gid,
    mode    => "0700",
    require => User[$git_username],
  }

  # Once this exists, you have to add the id_ecdsa.pub to any private
  # github repos you want to pull.
  exec { "create ${git_homedir}/.ssh/id_ecdsa":
    creates => "${git_homedir}/.ssh/id_ecdsa",
    user    => $git_username,
    command => "/usr/bin/ssh-keygen -t ecdsa -N '' -C '${::hostname}' -f ${git_homedir}/.ssh/id_ecdsa",
    require => File["${git_homedir}/.ssh"],
  }

  exec { "create /var/local/github_ssh_keys":
    creates => "/var/local/github_ssh_keys",
    command => "/usr/bin/ssh-keyscan github.com > /var/local/github_ssh_keys",
  }

  include nebula::profile::managed_known_hosts

  # Without this, the git user will not be able to pull from private
  # repos using ssh.
  concat_fragment { "github ssh keys":
    target  => "/etc/ssh/ssh_known_hosts",
    source  => "/var/local/github_ssh_keys",
    require => Exec["create /var/local/github_ssh_keys"],
  }
}
