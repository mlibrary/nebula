# frozen_string_literal: true
require 'spec_helper'

describe 'nebula::profile::hathitrust::solr6' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }
      # solr and dependencies
      it { is_expected.to contain_package('temurin-8-jre') }
      it { is_expected.to contain_package('solr') }
      it { is_expected.to contain_user('solr') }
      it { is_expected.to contain_service('solr') }

      # solr config
      it { is_expected.to contain_file('/etc/systemd/system/solr.service').with_content(%r{SOLR_INCLUDE=/s0lr/h0me/solr.in.sh}) }
      it { is_expected.to contain_file('/s0lr/h0me/log4j.properties').with_content(%r{solr.log=/s0lr/h0me/logs}) }
      it { is_expected.to contain_file('/s0lr/h0me/solr.xml') }
      it { is_expected.to contain_file('/s0lr/h0me/solr.in.sh')
        .with_content(/SOLR_PORT=2525/)
        .with_content(/-Dsolr.lock.type=single/)
        .with_content(%r|SOLR_HOME="/s0lr/h0me"|)
        .with_content(%r|SOLR_JAVA_HOME="/usr/lib/jvm/temurin-8-jre-amd64"|)
      }

      # firewall
      it { is_expected.to contain_firewall('200 Solr - Private: foobar net').with(source: '192.168.99.0/24') }
      it { is_expected.to contain_firewall('200 Solr - Staff: Net Two').with(source: '10.0.2.0/24') }
    end
  end
end
