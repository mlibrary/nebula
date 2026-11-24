# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::login" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:hiera_config) { "spec/fixtures/hiera/usergroups_config.yaml" }
      let(:facts) { os_facts }

      it { is_expected.to contain_class("nebula::profile::okta") }

      it "opens port 22 to staff networks" do
        is_expected.to contain_nebula__exposed_port("100 Staff SSH").with(
          port: 22,
          block: "umich::networks::staff"
        )
      end

      context "groups == [examplegroup1]" do
        let(:params) { {groups: ["examplegroup1"]} }

        it { is_expected.to contain_user("exampleuser1") }
        it { is_expected.to contain_user("exampleuser2") }
        it { is_expected.not_to contain_user("exampleuser3") }
      end

      context "groups == [examplegroup1, examplegroup2]" do
        let(:params) { {groups: ["examplegroup1", "examplegroup2"]} }

        it { is_expected.to contain_user("exampleuser1") }
        it { is_expected.to contain_user("exampleuser2") }
        it { is_expected.to contain_user("exampleuser3") }
      end
    end
  end
end
