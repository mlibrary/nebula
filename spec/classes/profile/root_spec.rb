# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::root" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to contain_file("/root/.bashrc")
        is_expected.to contain_file("/root/.profile")
      }
      it {
        is_expected.to contain_file("/root/.bash_profile")
          .with(ensure: "absent")
      }
    end
  end
end
