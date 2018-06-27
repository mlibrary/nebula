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
) {
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
        * => $vm_settings,
      ;
    }
  }
}
