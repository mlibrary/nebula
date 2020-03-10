# Copyright (c) 2020 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::root_ssh_private_keys
class nebula::profile::root_ssh_private_keys {

  $users = lookup('nebula::profile::authorized_keys::ssh_keys').keys

  $users.each |$user| {
    file { "/var/local/ssh/${user}":
      ensure => 'directory',
      mode   => '0700',
      owner  => $user,
      group  => 'root'
    }
    file { "/var/local/ssh/${user}/id_ecdsa":
      source => "puppet:///root-ssh-private-keys/${user}/id_ecdsa",
      mode   => '0600',
      owner  => $user,
      group  => 'root'
    }
    file { "/var/local/ssh/${user}/id_ecdsa.pub":
      source => "puppet:///root-ssh-private-keys/${user}/id_ecdsa.pub",
      mode   => '0644',
      owner  => $user,
      group  => 'root'
    }
  }

  file { '/var/local/ssh':
    ensure => 'directory',
  }

}
