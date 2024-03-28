# frozen_string_literal: true
require 'spec_helper'

describe 'nebula::role::hathitrust' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }
      it { is_expected.to contain_package('openafs-client') }

      context 'when $afs is false' do
        let(:params) { { afs: false } }

        it { is_expected.not_to contain_package('openafs-client') }
      end      
    end
  end
end
