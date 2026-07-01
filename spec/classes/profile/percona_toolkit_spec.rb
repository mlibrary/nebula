# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::percona_toolkit" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it "configures percona apt source" do
        is_expected.to contain_apt__source("percona").with_location(["https://repo.percona.com/apt/"])
        is_expected.to contain_apt__keyring("percona.asc")
      end

      it "installs percona-toolkit" do
        is_expected.to contain_package("percona-toolkit")
          .that_requires("Apt::Source[percona]")
      end
    end
  end
end
