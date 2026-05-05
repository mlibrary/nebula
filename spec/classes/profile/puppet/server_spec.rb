# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::puppet::server" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it "installs openvox-server" do
        is_expected.to contain_package("openvox-server")
        is_expected.not_to contain_package("puppetserver")
      end
      it { is_expected.to contain_service("puppetserver") }
    end
  end
end
