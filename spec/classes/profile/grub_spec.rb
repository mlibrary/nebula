# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::grub' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to contain_service('getty@hvc0').with(
          ensure: 'running',
          enable: true,
        )
      end

      context 'on a kvm vm' do
        let(:facts) { super().merge(is_virtual: true, virtual: 'kvm') }

        [
          ['^GRUB_CMDLINE_LINUX', 'GRUB_CMDLINE_LINUX="console=tty0 console=hvc0,9600n8"'],
          ['^GRUB_CMDLINE_LINUX_DEFAULT', 'GRUB_CMDLINE_LINUX_DEFAULT=""'],
          ['^#?GRUB_SERIAL_COMMAND', 'GRUB_SERIAL_COMMAND="serial --unit=0 --speed=9600"'],
          ['^#?GRUB_TERMINAL', 'GRUB_TERMINAL=serial'],
        ].each do |match, line|
          it do
            is_expected.to contain_file_line("/etc/default/grub: #{match}").with(
              path: '/etc/default/grub',
              line: line,
              match: "#{match}=",
              notify: 'Exec[/usr/sbin/update-grub]',
              before: 'Service[getty@hvc0]',
            )
          end
        end
      end

      [
        [true, 'virtbox', 'on a virtbox vm'],
        [false, 'kvm', 'on a somehow-physical kvm machine'],
        [false, 'physical', 'on a physical machine'],
      ].each do |isvirt, virt, desc|
        context desc do
          let(:facts) { super().merge(is_virtual: isvirt, virtual: virt) }

          [
            ['^GRUB_CMDLINE_LINUX', 'GRUB_CMDLINE_LINUX="console=tty0 console=ttyS1,115200n8 ixgbe.allow_unsupported_sfp=1"'],
            ['^GRUB_CMDLINE_LINUX_DEFAULT', 'GRUB_CMDLINE_LINUX_DEFAULT=""'],
            ['^#?GRUB_TERMINAL', 'GRUB_TERMINAL=console'],
          ].each do |match, line|
            it do
              is_expected.to contain_file_line("/etc/default/grub: #{match}").with(
                path: '/etc/default/grub',
                line: line,
                match: "#{match}=",
                notify: 'Exec[/usr/sbin/update-grub]',
                before: 'Service[getty@hvc0]',
              )
            end
          end
        end
      end

      it do
        is_expected.to contain_exec('/usr/sbin/update-grub')
          .with_refreshonly(true)
      end
    end
  end
end
