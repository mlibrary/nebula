# frozen_string_literal: true
require 'spec_helper'

describe 'nebula::profile::hathitrust::solr6::classic' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }
      it { is_expected.to contain_class('nebula::profile::loki') }
    end
  end
end
