# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::hathitrust::solr6::lss" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:hiera_config) { "spec/fixtures/hiera/hathitrust_config.yaml" }

      it { is_expected.to compile }
      it { is_expected.to contain_class("nebula::profile::hathitrust::solr6") }
      it { is_expected.to contain_file("/var/lib/solr/solr.in.sh").with_content(/SOLR_PORT=8081/) }

      it {
        expect(subject).to contain_file("/usr/local/bin/index-release")
          .with_content(/^base=\/htsolr\/lss$/)
          .with_content(/\/flags\/STOPLSSRELEASE/)
          .without_content(/^# run the first query to initialize catalog solr$/)
          .with_content(/^# run the first query to initialize lss solr$/)
      }

      it {
        expect(subject).to contain_cron("lss solr index release")
          .with(command: "/usr/local/bin/index-release > /tmp/index-release.log 2>&1 || /usr/bin/mail -s 'foo lss index release problem' nobody@default.invalid < /tmp/index-release.log")
      }

      context "when on primary site" do
        let(:params) do
          {is_primary_site: true}
        end

        it {
          expect(subject).to contain_file("/usr/local/bin/index-release")
            .with_content(/check whether release happened at mirror site/)
        }

        it {
          expect(subject).to contain_cron("lss solr index release")
            .with(hour: 6, minute: 0)
        }
      end

      context "when on mirror site" do
        let(:params) do
          {is_primary_site: false}
        end

        it {
          expect(subject).to contain_file("/usr/local/bin/index-release")
            .without_content(/check whether release happened at mirror site/)
        }

        it {
          expect(subject).to contain_cron("lss solr index release")
            .with(hour: 5, minute: 55)
        }
      end

      context "when on primary node" do
        let(:params) do
          {is_primary_node: true}
        end

        it {
          expect(subject).to contain_file("/usr/local/bin/index-release").with_content(%r{^touch "/htapps/babel/flags/web/lss-release-\$})
        }
      end

      context "when on non-primary node" do
        let(:params) do
          {is_primary_node: false}
        end

        it {
          expect(subject).to contain_file("/usr/local/bin/index-release").without_content(%r{^touch "/htapps/babel/flags/web/lss-release-\$})
        }
      end
    end
  end
end
