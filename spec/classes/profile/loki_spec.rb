# frozen_string_literal: true

require 'spec_helper'

describe 'nebula::profile::loki' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) {
        {
          log_files: {
            "solr" => ["/var/log/solr.log"],
            "apache" => ["/var/log/apache.log","/var/log/apache.err"],
          }
        }
      }

      it { is_expected.to compile }
      it { is_expected.to contain_apt__source('grafana') }
      it { is_expected.to contain_package('alloy') }
      it { is_expected.to contain_service('alloy') }

      it { is_expected.to contain_file('/var/lib/alloy/crt.pem') }
      it { is_expected.to contain_file('/var/lib/alloy/crt.key').with_mode('0600') }

      it "writes grafana alloy config" do
        is_expected.to contain_file('/etc/alloy/config.alloy')
          .with_content(/managed by Puppet/)
          .with_content(/stage.static_labels {values = {"hostname" = "/)
          .with_content(%r|url = "https://loki-gateway.loki/loki/api/v1/push"|)
      end

      it "writes loki.source.files components to config.alloy" do
        is_expected.to contain_file('/etc/alloy/config.alloy')
          .with_content(%r|loki.source.file "apache_\w{1,3}" {\n  targets    = \[{"__path__" = "/var/log/apache.err"}\]\n  forward_to = \[loki.process.service__apache.receiver\]\n}|)
      end

      it "writes loki.process components to config.alloy" do
        is_expected.to contain_file('/etc/alloy/config.alloy')
          .with_content(%r|loki.process "service__solr" {\n  stage.static_labels {values = {"service" = "solr"}}\n  forward_to = \[loki.process.hostname.receiver\]\n}|)
      end

      context("with loki url set") do
        let(:params) { {loki_endpoint_url: "https://loki.example.com/loki/api/v1/push"} }
        it "writes loki url to config.alloy" do
          is_expected.to contain_file('/etc/alloy/config.alloy')
            .with_content(%r|url = "https://loki.example.com/loki/api/v1/push"|)
        end
      end

    end
  end
end
