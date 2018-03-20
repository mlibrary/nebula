# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::vmhost
#
# Assert the existance of any number of virtual machines.
#
# @param defaults Default virtual machine settings
# @param vms VMs to set up as a mapping of vm names to their settings
#
# @see nebula::virtual_machine
#
# @example
#   include nebula::profile::vmhost
class nebula::profile::vmhost (
  Hash $defaults,
  Hash $vms,
) {
  package { 'libvirt-clients':
    ensure => 'installed',
  }

  package { 'virtinst':
    ensure => 'installed',
  }

  $vms.each |$vm_name, $vm_settings| {
    nebula::virtual_machine {
      default:
        * => $defaults,
      ;
      $vm_name:
        * => $vm_settings,
      ;
    }
  }
}
