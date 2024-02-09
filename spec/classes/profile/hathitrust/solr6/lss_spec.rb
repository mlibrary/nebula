# frozen_string_literal: true
require 'spec_helper'

describe 'nebula::profile::hathitrust::solr6::lss' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }
      it { is_expected.to contain_package('solr') }
      it { is_expected.to contain_file('/var/lib/solr/solr.in.sh').with_content(/SOLR_PORT=8081/) }
    end
  end
end
