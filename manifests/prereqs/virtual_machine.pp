# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::prereqs::virtual_machine
#
# Install packages required to host virtual machines.
#
# @example
#   require nebula::prereqs::virtual_machine
class nebula::prereqs::virtual_machine {
  package { 'libvirt-clients':
    ensure => 'installed',
  }

  package { 'virtinst':
    ensure => 'installed',
  }
}
