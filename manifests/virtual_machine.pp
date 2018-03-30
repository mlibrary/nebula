# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::virtual_machine
#
# Ensure the existence of a virtual machine. This creates a disk image
# and installs a new libvirt domain.
#
# @param addr The VM's outward-facing IPv4 address
# @param build The OS to install
# @param cpus Number of CPUs to allocate
# @param disk Disk image size in GiB
# @param ram RAM allocation in GiB
# @param autostart_path Path to virsh's autostart directory
# @param image_dir Path to directory holding the VM's disk image
# @param image_path Full path to the VM's disk image (in case you want
#   it to be called something other than [vmname].img)
# @param net_interface Preseed net interface
# @param netmask Preseed IPv4 netmask
# @param gateway Preseed IPv4 gateway
# @param nameservers Preseed IPv4 nameservers
# @param domain Domain to enter in the preseed file
# @param filehost URL to find preseed files puppetlabs-pc1-keyring.gpg
#   and puppet.conf
# @param timeout Number of seconds to wait for the VM to install before
#   giving up
#
# @example Declaring vmname.default.invalid
#   # This will define a virtual domain named `vmname` with default
#   # hardware, debian stretch, and a hostname of vmname.default.invalid.
#   nebula::virtual_machine { 'vmname':
#     $addr => '1.2.3.4',                   # while optional, it's a
#                                           # good idea to always
#                                           # assign an IP address
#   }
#
# @example Declaring supergood.awesome.com
#   # This will define a virtual domain named `supergood` with default
#   # hardware, debian stretch, and a hostname of supergood.awesome.com.
#   nebula::virtual_machine { 'supergood':
#     $addr     => '2.4.6.8',
#     $domain   => 'awesome.com',
#     $filehost => 'preseedfiles.awesome.com',
#   }
#
# @example Declaring a VM that may take up to 20 minutes to install
#   # Sometimes 10 minutes (600 seconds) isn't long enough.
#   nebula::virtual_machine { 'latebloomer':
#     $addr    => '3.6.9.12',
#     $timeout => 1200,
#   }
#
# @example Declaring a VM that may take forever to install
#   # Infinite patience rarely actually pays off.
#   nebula::virtual_machine { 'takeyourtime':
#     $addr    => '4.8.12.16',
#     $timeout => 0,                        # the special value of 0
#                                           # disables the timeout
#   }
define nebula::virtual_machine(
  String  $addr           = '127.0.0.1',
  String  $build          = 'stretch',
  Integer $cpus           = 2,
  Integer $disk           = 16,
  Integer $ram            = 1,
  String  $autostart_path = '/etc/libvirt/qemu/autostart',
  String  $image_dir      = '/var/lib/libvirt/images',
  String  $image_path     = '',
  String  $net_interface  = 'eth0',
  String  $netmask        = '255.255.255.0',
  String  $gateway        = '192.168.1.1',
  Array   $nameservers    = ['192.168.1.1'],
  String  $domain         = 'default.invalid',
  String  $filehost       = 'files.default.invalid',
  Integer $timeout        = 600,
) {
  require nebula::profile::vmhost::prereqs

  $prefix = "nebula::virtual_machine::${title}"
  $tmpdir = "/tmp/.virtual.${title}"
  $location = "http://ftp.us.debian.org/debian/dists/${build}/main/installer-amd64/"
  $ram_in_mb = $ram * 1024

  case $image_path {
    '':      { $full_image_path = "${image_dir}/${title}.img" }
    default: { $full_image_path = $image_path }
  }

  file { $tmpdir:
    ensure => 'directory',
  }

  file { "${tmpdir}/preseed.cfg":
    content => template('nebula/virtual_machine/stretch.cfg.erb'),
  }

  exec { "${prefix}::virt-install":
    require => [
      Package['libvirt-clients'],
      Package['virtinst'],
    ],
    creates => $full_image_path,
    timeout => $timeout,
    path    => [
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin',
    ],
    command => @("VIRT_INSTALL_EOF")
      /usr/bin/virt-install                                           \
        -n '${title}'                                                 \
        -r ${ram_in_mb}                                               \
        --vcpus ${cpus}                                               \
        --location ${location}                                        \
        --os-type=linux                                               \
        --disk '${full_image_path},size=${disk}'                      \
        --network bridge=br0,model=virtio                             \
        --network bridge=br1,model=virtio                             \
        --console pty,target_type=virtio                              \
        --virt-type kvm                                               \
        --graphics vnc                                                \
        --extra-args 'auto netcfg/disable_dhcp=true'                  \
        --initrd-inject '${tmpdir}/preseed.cfg'
      | VIRT_INSTALL_EOF
  }

  exec { "${prefix}::autostart":
    require => Exec["${prefix}::virt-install"],
    creates => "${autostart_path}/${title}.xml",
    command => "/usr/bin/virsh autostart ${title}",
  }
}
