# frozen_string_literal: true
require 'spec_helper'

describe 'nebula::role::hathitrust::solr::lss' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }
      it { is_expected.to contain_class('nebula::role::hathitrust') }
      it { is_expected.not_to contain_package('openafs-client') }
    end
  end
end
