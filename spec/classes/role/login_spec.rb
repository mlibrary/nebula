# frozen_string_literal: true

require "spec_helper"

describe "nebula::role::login" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.not_to contain_profile("nebula::profile::afs") }
      it { is_expected.not_to contain_package("openafs-client") }
      it { is_expected.not_to contain_package("openafs-krb5") }
    end
  end
end
