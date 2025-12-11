# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::hathitrust::mounts" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.deep_merge(networking: {ip: Faker::Internet.ip_v4_address, interfaces: {}}) }
      let(:hiera_config) { "spec/fixtures/hiera/hathitrust_config.yaml" }

      it { is_expected.to contain_package("nfs-common") }
      it "mounts /sdr and /htapps" do
        is_expected.to contain_nebula__nfs_mount("/sdr").with(
          remote_target: "truenas:/mnt/tank/sdr"
        )
        is_expected.to contain_nebula__nfs_mount("/htapps").with(
          remote_target: "truenas:/mnt/tank/htapps"
        )
      end

      it "symlinks /sdr#" do
        is_expected.to contain_file("/sdr1").with(
          ensure: "link",
          target: "/sdr/1"
        )

        is_expected.to contain_file("/sdr12").with(
          ensure: "link",
          target: "/sdr/12"
        )

        is_expected.to contain_file("/sdr24").with(
          ensure: "link",
          target: "/sdr/24"
        )
      end

      context "with /htapps specified as a non-nas mount" do
        let(:params) do
          {
            nas_mounts: [],
            other_nfs_mounts: {
              "/htapps" => {"remote_target" => "somehost:/htapps"}
            }
          }
        end

        it do
          expect(subject).to contain_mount("/htapps").with(
            device: "somehost:/htapps",
            fstype: "nfs"
          )
        end
      end
    end
  end
end
