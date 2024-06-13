# frozen_string_literal: true

require 'spec_helper'

describe 'nebula::log' do
  let(:title) { 'solr' }
  let(:params) {
    {
      files: ["/var/log/solr.log"],
    }
  }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it "writes solr log config to solr.alloy" do
        is_expected.to contain_file('/etc/alloy/solr.alloy')
          .with_content(%r|loki.source.file "solr_0" {\s+targets\s+= \[{"__path__" = "/var/log/solr.log"}\]\s+forward_to = \[loki.process.service__solr.receiver\]\n}|)
          .with_content(%r|loki.process "service__solr" {\s+stage.static_labels {values = {"service" = "solr"}}\s+forward_to = \[loki.process.hostname.receiver\]\n}|)
      end

      context 'when creating apache log' do
        let(:title) { 'apache' }
        let(:params) {
          {
            files: ["/var/log/apache.log","/var/log/apache.err"],
          }
        }

        it { is_expected.to compile }

        it "writes config for 'apache.log' source file to apache.alloy" do
          is_expected.to contain_file('/etc/alloy/apache.alloy')
            .with_content(%r|loki.source.file "apache_0" {\s+targets\s+= \[{"__path__" = "/var/log/apache.log"}\]\s+forward_to = \[loki.process.service__apache.receiver\]\n}|)
        end

        it "writes config for 'apache.err' source file to apache.alloy" do
          is_expected.to contain_file('/etc/alloy/apache.alloy')
            .with_content(%r|loki.source.file "apache_1" {\s+targets\s+= \[{"__path__" = "/var/log/apache.err"}\]\s+forward_to = \[loki.process.service__apache.receiver\]\n}|)
        end

        it "writes config for apache label to apache.alloy" do
          is_expected.to contain_file('/etc/alloy/apache.alloy')
            .with_content(%r|loki.process "service__apache" {\s+stage.static_labels {values = {"service" = "apache"}}\s+forward_to = \[loki.process.hostname.receiver\]\n}|)
        end

      end
    end
  end
end
