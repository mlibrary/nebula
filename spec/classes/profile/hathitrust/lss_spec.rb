# frozen_string_literal: true
require 'spec_helper'

describe 'nebula::profile::hathitrust::lss' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }
      # solr and dependencies
      it { is_expected.to contain_package('openjdk-11-jre-headless') }
      it { is_expected.to contain_package('solr') }
      it { is_expected.to contain_user('solr') }
      it { is_expected.to contain_service('solr') }

      # solr config
      it { is_expected.to contain_file('/etc/systemd/system/solr.service').with_content(%r{SOLR_INCLUDE=/s0lr/h0me/solr.in.sh}) }
      it { is_expected.to contain_file('/s0lr/h0me/log4j.properties').with_content(%r{solr.log=/s0lr/h0me/logs}) }
      it { is_expected.to contain_file('/s0lr/h0me/solr.xml') }
      it { is_expected.to contain_file('/s0lr/h0me/solr.in.sh').with_content(/SOLR_PORT=2525/).with_content(%r{SOLR_HOME="/s0lr/h0me"}) }
      it { is_expected.to contain_file('Solr LSS Core').with(ensure: 'link', path: '/s0lr/h0me/foobar9000', target: '/htsolr/current_snap/cores/foobar9000') }
      it { is_expected.to contain_file('/s0lr/h0me/lib').with(ensure: 'link', target: '/htsolr/current_snap/shared/lib') }

      it { is_expected.to contain_file('/htsolr/serve/lss-shared').with(ensure: 'link', target: '/htsolr/current_snap/shared') }
      it { is_expected.to contain_file('/htsolr/serve/lss-foobar9000').with(ensure: 'link', target: '/htsolr/current_snap/cores/foobar9000') }

      # release script
      it { is_expected.to contain_file('/usr/local/bin/index-release-lss')
        .with_content(%r{^TARGET=/htsolr/lss/.snapshot/htsolr-lss_\$\{TODAY\}$})
        .with_content(%r{babel.hathitrust.org:443:5.4.3.2})
        .with_content(%r{ls \$\{TARGET\}/cores/foobar9000/core-foobar9000x/data/index/\*\.fdt})
      }
      it { is_expected.to contain_cron('lss solr index release')
        .with(command: "/usr/local/bin/index-release-lss > /tmp/index-release-lss.log 2>&1 || /usr/bin/mail -s 'foo lss index release problem' nobody@default.invalid < /tmp/index-release-lss.log")
      }

      context 'on primary site' do
        let(:params) do
          { is_primary_site: true }
        end
        it { is_expected.to contain_file('/usr/local/bin/index-release-lss').with_content(%r{^if ! curl -A SOLR -s --retry 5 --fail https://babel.hathitrust.org}) }
        it { is_expected.to contain_cron('lss solr index release')
          .with(hour: 6, minute: 0)
        }
      end
      context 'on mirror site' do
        let(:params) do
          { is_primary_site: false }
        end
        it { is_expected.to contain_file('/usr/local/bin/index-release-lss').with_content(%r{^#if ! curl -A SOLR -s --retry 5 --fail https://babel.hathitrust.org}) }
        it { is_expected.to contain_cron('lss solr index release')
          .with(hour: 5, minute: 55)
        }
      end

      context 'on primary node' do
        let(:params) do
          { is_primary_node: true }
        end
        it { is_expected.to contain_file('/usr/local/bin/index-release-lss').with_content(%r{^touch /htapps/babel/flags/web/lss-release-\$\{TODAY\}$}) }
      end
      context 'on non-primary node' do
        let(:params) do
          { is_primary_node: false }
        end
        it { is_expected.to contain_file('/usr/local/bin/index-release-lss').with_content(%r{^#touch /htapps/babel/flags/web/lss-release-\$\{TODAY\}$}) }
      end

      it { is_expected.to contain_firewall('200 Solr - Private: foobar net').with(source: '192.168.99.0/24') }
      it { is_expected.to contain_firewall('200 Solr - Staff: Net Two').with(source: '10.0.2.0/24') }
    end
  end
end
