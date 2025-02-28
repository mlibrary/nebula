# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.

# nebula::profile::grub
#
# Manage grub.
#
# @param kernel_args Optionally override generated kernel args.
#
# @example
#   include nebula::profile::grub
class nebula::profile::grub (
  Optional[String] $kernel_args = undef,
) {
  if $facts['is_virtual'] and $facts['virtual'] == 'kvm' {
    $getty = 'getty@hvc0'
    $default_grub_cmdline = 'console=tty0 console=hvc0,9600n8'
    $grub_terminal = 'serial'
    $grub_serial_command = 'serial --unit=0 --speed=9600'
  } else {
    $getty = 'serial-getty@ttyS1'
    $default_grub_cmdline = 'console=tty0 console=ttyS1,115200n8'
    $grub_terminal = 'console'
    $grub_serial_command = 'serial'
  }

  if $kernel_args {
    $grub_cmdline = $kernel_args
  } else {
    $grub_cmdline = $default_grub_cmdline
  }

  service { $getty:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/etc/default/grub.d/grub.cfg':
    notify  => Exec['/usr/sbin/update-grub'],
    before  => Service[$getty],
    content => template('nebula/profile/grub/grub.cfg.erb'),
  }

  exec { '/usr/sbin/update-grub':
    refreshonly => true,
  }
}
