# frozen_string_literal: true

require "spec_helper"

describe "nebula::nfs_mount" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { "/some/local/path" }
      let(:params) do
        {
          remote_target: "somehost:/some/remote/path"
        }
      end

      it { is_expected.to compile }

      it { is_expected.to contain_file("/some/local/path").with_ensure("directory") }
      it { is_expected.to contain_mount("/some/local/path").with_device("somehost:/some/remote/path") }
      it { is_expected.to contain_package("nfs-common").with_ensure(/(present|installed)/) }
    end
  end
end
