# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::vmhost::prereqs
#
# @example
#   include nebula::profile::vmhost::prereqs
class nebula::profile::vmhost::prereqs {
  stdlib::ensure_packages([
    'libvirt-clients',
    'virtinst', # virt-install
    'libvirt-daemon',
    'libvirt-daemon-system',
    'virt-manager',
    'virt-viewer',
    'libguestfs-tools', # virt-resize
  ])
}
