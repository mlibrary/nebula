# Copyright (c) 2019 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::cifs_mount
#
# Configure a CIFS/SMB mount.
##
# @param user The user to mount as
# @param credentials The path to the credentials to use. They will be stored at /etc/default/$user-credentials
# @param remote_target The UNC of the server and path to mount
# @param options The options to pass to the mount command
# @param monitored Whether this mount should be monitored with monitor_pl
# @param private_network Whether to wait until the private network is up before attempting to mount
#
# @example
#   nebula::cifs_mount { '/mnt/whatever':
#     user          => 'some_domain_user',
#     remote_target => '//somehost/whatever',
#     uid           => 'someuser',
#     gid           => 'somegroup',
#
#  }
define nebula::cifs_mount(
  String $remote_target,
  String $uid,
  String $gid,
  String $user,
  String $credentials = "puppet:///cifs-credentials/${user}-credentials",
  String $file_mode = '0644',
  String $dir_mode = '0755',
  String $extra_options = 'vers=2.1'
) {
  ensure_packages(['cifs-utils'], {'ensure' => 'present'})

  file { $title:
    ensure => 'directory',
  }

  file { "/etc/default/${user}-credentials":
    source => $credentials,
    mode   => '0400',
    owner  => 'root',
    group  => 'root'
  }

  mount { $title:
    ensure  => 'mounted',
    device  => $remote_target,
    options => "credentials=${credentials},uid=${uid},gid=${gid},file_mode=${file_mode},dir_mode=${dir_mode},${extra_options}",
    fstype  => 'cifs',
    require => Package[cifs-utils]
  }

}
