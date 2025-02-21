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
    $default_grub_cmdline = 'console=tty0 console=ttyS1,115200n8 ixgbe.allow_unsupported_sfp=1'
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

  # TODO: Delete after February 2025
  # This should revert /etc/default/grub to as close to stock as possible.
  # Once it has run on all hosts this stanza should be removed.
  file_line {
    default:
      path   => '/etc/default/grub',
      notify => Exec['/usr/sbin/update-grub'],
      before => Service[$getty],
    ;
    '/etc/default/grub: ^GRUB_CMDLINE_LINUX':
      line  => 'GRUB_CMDLINE_LINUX=""',
      match => '^GRUB_CMDLINE_LINUX=',
    ;
    '/etc/default/grub: ^GRUB_CMDLINE_LINUX_DEFAULT':
      line  => 'GRUB_CMDLINE_LINUX_DEFAULT="quiet"',
      match => '^GRUB_CMDLINE_LINUX_DEFAULT=',
    ;
    '/etc/default/grub: ^#?GRUB_TERMINAL':
      line  => '#GRUB_TERMINAL=console',
      match => '^#?GRUB_TERMINAL=',
    ;
    '/etc/default/grub: ^#?GRUB_SERIAL_COMMAND':
      ensure            => absent,
      match             => '^GRUB_SERIAL_COMMAND=',
      match_for_absence => true,
    ;
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
