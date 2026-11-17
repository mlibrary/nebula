# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::base::packages" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to contain_package("ripgrep") }
      it { is_expected.to contain_package("zstd") }

      case os
      when /^debian-12-/, /^ubuntu-(22|24).04-/
        it { is_expected.not_to contain_package("wtmpdb") }
      else
        it { is_expected.to contain_package("wtmpdb") }
      end
    end
  end
end
