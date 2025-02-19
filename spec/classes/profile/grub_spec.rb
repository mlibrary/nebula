# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::grub" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context "when on a kvm vm" do
        let(:facts) { super().merge(is_virtual: true, virtual: "kvm") }
        it {
          is_expected.to contain_file("/etc/default/grub.d/grub.cfg")
            .with_content(/^GRUB_CMDLINE_LINUX="console=tty0 console=hvc0,9600n8"$/)
            .with_content(/^GRUB_CMDLINE_LINUX_DEFAULT=""$/)
            .with_content(/^GRUB_SERIAL_COMMAND="serial --unit=0 --speed=9600"$/)
            .with_content(/^GRUB_TERMINAL="serial"$/)
        }

        it do
          expect(subject).to contain_service("getty@hvc0").with(
            ensure: "running",
            enable: true
          )
        end
      end

      [
        [true, "virtbox", "on a virtbox vm"],
        [false, "kvm", "on a somehow-physical kvm machine"],
        [false, "physical", "on a physical machine"]
      ].each do |isvirt, virt, desc|
        context desc do
          let(:facts) { super().merge(is_virtual: isvirt, virtual: virt) }

          it {
            is_expected.to contain_file("/etc/default/grub.d/grub.cfg")
              .with_content(/^GRUB_CMDLINE_LINUX="console=tty0 console=ttyS1,115200n8 ixgbe.allow_unsupported_sfp=1"$/)
              .with_content(/^GRUB_CMDLINE_LINUX_DEFAULT=""$/)
              .with_content(/^GRUB_SERIAL_COMMAND="serial"$/)
              .with_content(/^GRUB_TERMINAL="console"$/)
          }

          it do
            expect(subject).to contain_service("serial-getty@ttyS1").with(
              ensure: "running",
              enable: true
            )
          end
        end
      end

      it do
        expect(subject).to contain_exec("/usr/sbin/update-grub")
          .with_refreshonly(true)
      end
    end
  end
end
