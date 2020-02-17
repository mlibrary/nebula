# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# The ruby application components of a named instance, including users, groups,
# directories, systemd, and configuring puma.
#
# This defined type should not be invoked directly. See named_instance.pp
#
# @param path The path where the application will be deployed. By convention, this
#   does not differ from one host to another.
# @param data_path The path to store application data
# @param log_path The path to store application logs
# @param tmp_path The path to store temporary artifacts created by the application
# @param uid The uid of the application user
# @param gid The gid of the application user
# @param mysql_host The instance's mysql host
# @param users A list of users that should be added to the application's group
# @param subservices A list of systemd services that should be restarted with this
#   instance. This list should only include the top level of the service tree; i.e.,
#   given a service my_app_x that depends on my_app_y, you should only include my_app_y.
# @param mysql_exec_path
# @param mysql_user The mysql user the instance uses to connect to the database
# @param mysql_password The password for the mysql user
define nebula::named_instance::app (
  String        $path,
  String        $data_path,
  String        $log_path,
  String        $tmp_path,
  Integer       $uid,
  Integer       $gid,
  String        $mysql_host,
  Array[String] $users,
  Array[String] $subservices,
  String        $mysql_exec_path = '',
  Optional[String] $mysql_user = undef,
  Optional[String] $mysql_password = undef,
) {
  require nebula::virtual::users

  $pubkey = Class['Nebula::Profile::Named_instances']['pubkey']
  $puma_config = Class['Nebula::Profile::Named_instances']['puma_config']
  $puma_wrapper = Class['Nebula::Profile::Named_instances']['puma_wrapper']
  $create_database = Class['Nebula::Profile::Named_instances']['create_databases']

  include nebula::systemd::daemon_reload

  # Create the application user's group
  group { $title:
    ensure => 'present',
    gid    => $gid,
  }

  # Add sudoers and passed users to the group
  (lookup('nebula::usergroup::membership')['sudo'] + $users).unique.each |$user| {
    exec { "${user} ${title} membership":
      unless  => "/bin/grep -q '${title}\\S*${user}' /etc/group",
      onlyif  => "/usr/bin/id ${user}",
      command => "/usr/sbin/usermod -aG ${title} ${user}",
    }

    if lookup('nebula::virtual::users::all_users').has_key($user) {
      realize User[$user]
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
    mode   => '0755',
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

  # Create the application directory if it is separate
  if $path != "/var/local/${title}" {
    file { $path:
      ensure => 'directory',
      mode   => '0755',
      owner  => $uid,
      group  => $gid,
    }
  }

  # Create the application data directory
  file { $data_path:
    ensure => 'directory',
    mode   => '0750',
    owner  => $uid,
    group  => $gid,
  }

  # Create the application log directory
  file { $log_path:
    ensure => 'directory',
    mode   => '0750',
    owner  => $uid,
    group  => $gid,
  }

  # Create the application tmp directory
  file { $tmp_path:
    ensure => 'directory',
    mode   => '0750',
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

  if $create_database and $mysql_user and $mysql_password  {
    mysql::db { $title:
      mysql_exec_path => $mysql_exec_path,
      user            => $mysql_user,
      password        => $mysql_password,
      host            => '%',
    }
  }

  @@concat_fragment { "${title} deploy init deploy.sites.nodes.${::hostname}":
    target  => "${title} deploy init",
    content => {deploy => {sites => {nodes => {$::hostname => $::datacenter}}}}.to_json,
  }

}
