# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# A named instance
#
# @example
define nebula::named_instance(
  String            $path,
  Integer           $uid,
  Integer           $gid,
  String            $pubkey,
  String            $puma_config,
  String            $puma_wrapper,
  Array[String]     $users = [],
  Array[String]     $subservices = [],
) {

  include nebula::systemd::daemon_reload

  # Create the application user's group
  group { $title:
    ensure => 'present',
    gid    => $gid,
  }

  # Add sudoers and passed users to the group
  (lookup('nebula::usergroup::membership')['sudo'] + $users).each |$user| {
    exec { "${user} ${title} membership":
      unless  => "/bin/grep -q ${title}\\S*${user} /etc/group",
      onlyif  => "/usr/bin/id ${user}",
      command => "/usr/sbin/usermod -aG ${title} ${user}",
    }
  }

  # Create the application user
  user { $title:
    ensure  => 'present',
    comment => 'Application User',
    uid     => $uid,
    gid     => $gid,
    home    => "/var/local/${title}",
    shell   => '/bin/bash',
    system  => true,
  }

  # Create the application user's home directory
  file { "/var/local/${title}":
    ensure => 'directory',
    mode   => '0700',
    owner  => $uid,
    group  => $gid,
  }

  # Install the authorized ssh pubkey for deployer
  ssh_authorized_key { "${title} pubkey":
    ensure => 'present',
    user   => $title,
    type   => 'ssh-rsa',
    key    => $pubkey,
  }

  # Create the application directory
  file { $path:
    ensure => 'directory',
    mode   => '2775',
    owner  => $uid,
    group  => $gid,
  }

  # Stop and disable the old services
  # This is setup to run after the files have been deleted but before daemon-reload,
  # else systemd will not be able to find the service to stop it.
  service { "app-puma@${title}.service":
    ensure   => 'stopped',
    enable   => false,
    provider => 'systemd',
    before   => Class['nebula::systemd::daemon_reload']
  }

  # Remove the old style systemd puma file
  file { "/etc/systemd/system/app-puma@${title}.service.d":
    ensure  => 'absent',
    recurse => true,
    force   => true,
    notify  => [
      Class['nebula::systemd::daemon_reload'],
      Service["app-puma@${title}.service"],
    ],
  }

  # Remove the old style systemd resque-pool file
  file { "/etc/systemd/system/resque-pool@${title}.service.d":
    ensure  => 'absent',
    recurse => true,
    force   => true,
    notify  => [
      Class['nebula::systemd::daemon_reload'],
      Service["app-puma@${title}.service"],
    ],
  }

  # Lookup rbenv root for use in templates
  $rbenv_root = lookup('nebula::profile::ruby::install_dir')

  # Add current-style systemd primary target file
  file { "/etc/systemd/system/${title}.target":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('nebula/named_instance/main.target.erb'),
    notify  => [
      Class['nebula::systemd::daemon_reload'],
      Service["${title}.target"],
    ],
  }

  # Add current-style systemd puma file
  file { "/etc/systemd/system/puma@${title}.service":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('nebula/named_instance/puma.service.erb'),
    notify  => [
      Class['nebula::systemd::daemon_reload'],
      Service["${title}.target"],
    ],
  }

  # Add a systemd service file for each subservice
  $subservices.each |String $subservice| {
    file { "/etc/systemd/system/${subservice}@${title}.service":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('nebula/named_instance/subservice.service.erb'),
      notify  => [
        Class['nebula::systemd::daemon_reload'],
        Service["${title}.target"],
      ],
    }
  }

  # Enable and start the new service
  # This is setup to run exactly once after we've made any changes,
  # run daemon-reload, and installed the sudoers file.
  service { "${title}.target":
    ensure   => 'running',
    enable   => true,
    provider => 'systemd',
    require  => [
      Class['nebula::systemd::daemon_reload'],
      File["/etc/sudoers.d/${title}"]
    ]
  }

  # Remove old-style sudoers file
  file { "/etc/sudoers.d/app-puma-${title}":
    ensure => 'absent',
  }

  # Add current-style sudoers file
  file { "/etc/sudoers.d/${title}":
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    content => template('nebula/named_instance/sudoers.erb'),
  }

}

