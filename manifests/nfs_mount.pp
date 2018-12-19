# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::nfs_mount
#
# Configure an NFS mount. Optionally, configure requirements for smartconnect
# and configure web server monitoring for the mount.
#
# @param remote_target The address of the server and path to mount
# @param options The options to pass to the mount command
# @param monitored Whether this mount should be monitored with monitor_pl
# @param private_network Whether to wait until the private network is up before attempting to mount
#
# @example
#   nebula::nfs_mount { '/mnt/whatever':
#     remote_target => 'somehost:/whatever',
#     options       => 'ro,auto,hard,intr,nfsvers=3',
#     monitored     => true
#  }
define nebula::nfs_mount(
  String $remote_target,
  String $options = 'auto,hard,nfsvers=3',
  Boolean $monitored = true,
  Boolean $private_network = true
) {
  ensure_packages(['nfs-common'], {'ensure' => 'present'})

  file { $title:
    ensure => 'directory',
  }

  mount { $title:
    ensure  => 'mounted',
    device  => $remote_target,
    options => $options,
    fstype  => 'nfs',
    require => Package[nfs-common]
  }

  if($private_network) {
    Mount[$title] {
      tag => 'private_network'
    }
  }

  if($monitored) {
    concat_fragment { "monitor nfs ${title}":
      tag     => 'monitor_config',
      content => { 'nfs' => [$title] }.to_yaml
    }
  }
}
