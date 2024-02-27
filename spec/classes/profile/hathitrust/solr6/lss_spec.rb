# frozen_string_literal: true
require 'spec_helper'

describe 'nebula::profile::hathitrust::solr6::lss' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { 'spec/fixtures/hiera/hathitrust_config.yaml' }

      it { is_expected.to compile }
      it { is_expected.to contain_class('nebula::profile::hathitrust::solr6') }
      it { is_expected.to contain_file('/var/lib/solr/solr.in.sh').with_content(/SOLR_PORT=8081/) }
      it { is_expected.to contain_file('/usr/local/bin/index-release')
        .with_content(%r|BASE=/htsolr/lss|)
        .with_content(%r|^SNAP=".snapshot/htsolr-lss_\${TODAY}"$|)
        .with_content(%r|CORES="66 99"|)
        .with_content(%r|/flags/STOPLSSRELEASE|)
        .with_content(%r|/bin/echo "STOPLSSRELEASE flag present|)
        .with_content(%r|curl -A SOLR -s --retry 5 --fail https://babel.hathitrust.org/flags/web/lss-release-|)
        .with_content(%r{babel.hathitrust.org:443:5.4.3.2})
        .with_content(%r|SEGMENTS=`ls \${BASE}/cores/\${s}/\${SNAP}/core-\${s}x/data/index/|)
        .without_content(%r|if \[ \${SEGMENTS} -eq 0 \];|)
           .with_content(%r(if \[ \${SEGMENTS} -lt 1 \] \|\| \[ \${SEGMENTS} -gt 2 \];))
        .with_content(%r|rm -f \${SYMLINKBASE}/lss-\${s} && ln -s \${BASE}/cores/\${s}/\${SNAP} \${SYMLINKBASE}/lss-\${s}$|)
        .with_content(/^## run the first query to initialize catalog solr$/)
        .with_content(/^# run the first query to initialize lss solr$/)
      }
      it { is_expected.to contain_cron('lss solr index release')
        .with(command: "/usr/local/bin/index-release > /tmp/index-release.log 2>&1 || /usr/bin/mail -s 'foo lss index release problem' nobody@default.invalid < /tmp/index-release.log")
      }

      context 'on primary site' do
        let(:params) do
          { is_primary_site: true }
        end
        it { is_expected.to contain_file('/usr/local/bin/index-release').with_content(%r{^if ! curl -A SOLR -s --retry 5 --fail https://babel.hathitrust.org}) }
        it { is_expected.to contain_cron('lss solr index release')
          .with(hour: 6, minute: 0)
        }
      end
      context 'on mirror site' do
        let(:params) do
          { is_primary_site: false }
        end
        it { is_expected.to contain_file('/usr/local/bin/index-release').with_content(%r{^#if ! curl -A SOLR -s --retry 5 --fail https://babel.hathitrust.org}) }
        it { is_expected.to contain_cron('lss solr index release')
          .with(hour: 5, minute: 55)
        }
      end

      context 'on primary node' do
        let(:params) do
          { is_primary_node: true }
        end
        it {
          is_expected.to contain_file('/usr/local/bin/index-release').with_content(%r{^touch /htapps/babel/flags/web/lss-release-\${TODAY}$})
        }
      end
      context 'on non-primary node' do
        let(:params) do
          { is_primary_node: false }
        end
        it {
          is_expected.to contain_file('/usr/local/bin/index-release').with_content(%r{^#touch /htapps/babel/flags/web/lss-release-\${TODAY}$})
        }
      end

    end
  end
end
