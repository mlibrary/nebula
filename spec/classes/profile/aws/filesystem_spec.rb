# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::aws::filesystem" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge("disks" => {
          "xvda" => "some other stuff"
        })
      end

      it { is_expected.to compile.with_all_deps }

      context "with /dev/xvdb present" do
        let(:facts) do
          os_facts.merge("disks" => {
            "xvdb" => "some stuff"
          })
        end

        it "formats the disk" do
          expect(subject).to contain_filesystem("/dev/xvdb")
            .with_ensure("present")
            .with_fs_type("ext4")
        end

        it "creates the mountpoint" do
          expect(subject).to contain_file("/l")
            .with_ensure("directory")
        end

        it "mounts the disk" do
          expect(subject).to contain_mount("/l")
            .with_ensure("mounted")
            .with_name("/l")
            .with_device("/dev/xvdb")
            .with_fstype("ext4")
        end
      end

      context "without /dev/xvdb present" do
        it { is_expected.not_to contain_filesystem("/dev/xvdb") }
        it { is_expected.not_to contain_file("/l") }
        it { is_expected.not_to contain_mount("/l") }
      end
    end
  end
end
