# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::vmhost::prereqs
#
# @example
#   include nebula::profile::vmhost::prereqs
class nebula::profile::vmhost::prereqs {
  package { 'libvirt-clients':
    ensure => 'installed',
  }

  # virt-install
  package { 'virtinst':
    ensure => 'installed',
  }

  package { 'libvirt-daemon':
    ensure => 'installed'
  }

  package { 'libvirt-daemon-system':
    ensure => 'installed'
  }

  package { 'virt-manager':
    ensure => 'installed'
  }

  package { 'virt-viewer':
    ensure => 'installed'
  }

  package { 'qemu':
    ensure => 'installed'
  }

  package { 'qemu-kvm':
    ensure => 'installed'
  }

  # virt-resize
  package { 'libguestfs-tools':
    ensure => 'installed'
  }
}
