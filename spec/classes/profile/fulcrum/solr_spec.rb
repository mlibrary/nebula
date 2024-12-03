# frozen_string_literal: true

require 'spec_helper'

describe 'nebula::profile::fulcrum::solr' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/fulcrum_config.yaml' }

      it { is_expected.to compile }

      it { is_expected.to contain_package('temurin-11-jre') }

      it { is_expected.to contain_file('/etc/environment').with_content(%r{JAVA_HOME=/usr/lib/jvm/temurin-11-jre-amd64}) }
    end
  end
end
