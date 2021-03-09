# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::vmhost::host
#
# Assert the existance of any number of virtual machines.
#
# @param defaults Default virtual machine settings
# @param vms VMs to set up as a mapping of vm names to their settings
#
# @see nebula::virtual_machine
#
# @example
#   include nebula::profile::vmhost::host
class nebula::profile::vmhost::host (
  Hash    $vms,
  String  $build,
  Integer $cpus,
  Integer $disk,
  Integer $ram,
  String  $domain,
  String  $filehost,
  String  $image_dir,
  String  $net_interface,
  String  $netmask,
  String  $gateway,
  Array   $nameservers,
  String  $local_storage = '',
  String  $local_storage_size = '',
) {

  file { '/etc/default/libvirt-guests':
    content => template('nebula/profile/vmhost/defaults.sh.erb'),
  }

  if $local_storage != '' {
    logical_volume { 'vmimages':
      ensure       => 'present',
      volume_group => 'internal',
      size         => $local_storage_size
    }

    filesystem { '/dev/mapper/internal-vmimages':
      ensure  => 'present',
      fs_type => 'ext4',
      require => ['Logical_volume[vmimages]']
    }

    file { $local_storage:
      ensure => 'directory'
    }

    mount { $local_storage:
      ensure  =>  'mounted',
      device  =>  '/dev/mapper/internal-vmimages',
      atboot  =>  true,
      fstype  =>  'ext4',
      options =>  'defaults',
      require => ["File[${local_storage}]"]
    }

    $vm_requires = ["Mount[${local_storage}]"]
  } else {
    $vm_requires = []
  }

  $vms.each |$vm_name, $vm_settings| {
    nebula::virtual_machine {
      default:
        build         => $build,
        cpus          => $cpus,
        disk          => $disk,
        ram           => $ram,
        domain        => $domain,
        filehost      => $filehost,
        image_dir     => $image_dir,
        net_interface => $net_interface,
        netmask       => $netmask,
        gateway       => $gateway,
        nameservers   => $nameservers,
      ;
      $vm_name:
        *       => $vm_settings,
        require => $vm_requires
      ;
    }
  }
}
