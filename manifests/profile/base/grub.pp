# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::base::grub
#
# Manage grub.
#
# @example
#   include nebula::profile::base::grub
class nebula::profile::base::grub {
  service { 'getty@hvc0':
    ensure => 'running',
    enable => true,
  }

  if $::is_virtual and $::virtual == 'kvm' {
    file_line {
      default:
        path   => '/etc/default/grub',
        notify => Exec['/usr/sbin/update-grub'],
        before => Service['getty@hvc0'],
      ;
      '/etc/default/grub: ^GRUB_CMDLINE_LINUX':
        line  => 'GRUB_CMDLINE_LINUX="console=tty0 console=hvc0,9600n8"',
        match => '^GRUB_CMDLINE_LINUX=',
      ;
      '/etc/default/grub: ^GRUB_CMDLINE_LINUX_DEFAULT':
        line  => 'GRUB_CMDLINE_LINUX_DEFAULT=""',
        match => '^GRUB_CMDLINE_LINUX_DEFAULT=',
      ;
      '/etc/default/grub: ^#?GRUB_SERIAL_COMMAND':
        line  => 'GRUB_SERIAL_COMMAND="serial --unit=0 --speed=9600"',
        match => '^#?GRUB_SERIAL_COMMAND=',
      ;
      '/etc/default/grub: ^#?GRUB_TERMINAL':
        line  => 'GRUB_TERMINAL=serial',
        match => '^#?GRUB_TERMINAL=',
      ;
    }
  } else {
    file_line {
      default:
        path   => '/etc/default/grub',
        notify => Exec['/usr/sbin/update-grub'],
        before => Service['getty@hvc0'],
      ;
      '/etc/default/grub: ^GRUB_CMDLINE_LINUX':
        line  => 'GRUB_CMDLINE_LINUX="console=tty0 console=ttyS1,115200n8 ixgbe.allow_unsupported_sfp=1"',
        match => '^GRUB_CMDLINE_LINUX=',
      ;
      '/etc/default/grub: ^GRUB_CMDLINE_LINUX_DEFAULT':
        line  => 'GRUB_CMDLINE_LINUX_DEFAULT=""',
        match => '^GRUB_CMDLINE_LINUX_DEFAULT=',
      ;
      '/etc/default/grub: ^#?GRUB_TERMINAL':
        line  => 'GRUB_TERMINAL=console',
        match => '^#?GRUB_TERMINAL=',
      ;
    }
  }

  exec { '/usr/sbin/update-grub':
    refreshonly => true,
  }
}
