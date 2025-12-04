# frozen_string_literal: true

# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::search::catalog::solr_monitor" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(mlibrary_ip_addresses: {
          "public" => [os_facts[:ipaddress]],
          "private" => []
        })
      end

      it { is_expected.to compile }

      it { is_expected.to contain_service("metrics-catalog-serve") }
      it { is_expected.to contain_service("metrics-catalog-reindex") }

      it { is_expected.to contain_exec("catalog serve solr metrics reload systemd").that_notifies("Service[metrics-catalog-serve]") }
      it { is_expected.to contain_exec("catalog reindex solr metrics reload systemd").that_notifies("Service[metrics-catalog-reindex]") }

      it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-serve.service").with_content(/ExecStart=\/opt\/catalog\/serve\/bin\/metrics -p 9983 -b http:\/\/localhost:8983\/solr -f \/opt\/catalog\/serve\/config\/metrics\.xml/) }
      it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-reindex.service").with_content(/ExecStart=\/opt\/catalog\/reindex\/bin\/metrics -p 9984 -b http:\/\/localhost:8984\/solr -f \/opt\/catalog\/reindex\/config\/metrics\.xml/) }

      context "when serve_port is set to 8765" do
        let(:hiera_config) { "spec/fixtures/hiera/search_solr_monitor_config.yaml" }

        it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-serve.service").with_content(/ExecStart=.*\s-b http:\/\/localhost:8765\/solr\s/) }
      end

      context "when serve_metrics_bin is set to /usr/bin/solr_metrics" do
        let(:params) { {serve_metrics_bin: "/usr/bin/solr_metrics"} }

        it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-serve.service").with_content(/ExecStart=\/usr\/bin\/solr_metrics/) }
      end

      context "when serve_metrics_port is set to 9876" do
        let(:params) { {serve_metrics_port: 9876} }

        it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-serve.service").with_content(/ExecStart=.*\s-p 9876\s/) }
      end

      context "when serve_metrics_config is set to /etc/catalog/serve/solr_metrics.xml" do
        let(:params) { {serve_metrics_config: "/etc/catalog/serve/solr_metrics.xml"} }

        it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-serve.service").with_content(/ExecStart=.*\s-f \/etc\/catalog\/serve\/solr_metrics\.xml\s/) }
      end

      context "when reindex_port is set to 9876" do
        let(:hiera_config) { "spec/fixtures/hiera/search_solr_monitor_config.yaml" }

        it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-reindex.service").with_content(/ExecStart=.*\s-b http:\/\/localhost:9876\/solr\s/) }
      end

      context "when reindex_metrics_bin is set to /usr/bin/solr_metrics" do
        let(:params) { {reindex_metrics_bin: "/usr/bin/solr_metrics"} }

        it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-reindex.service").with_content(/ExecStart=\/usr\/bin\/solr_metrics/) }
      end

      context "when reindex_metrics_port is set to 9876" do
        let(:params) { {reindex_metrics_port: 9876} }

        it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-reindex.service").with_content(/ExecStart=.*\s-p 9876\s/) }
      end

      context "when reindex_metrics_config is set to /etc/catalog/reindex/solr_metrics.xml" do
        let(:params) { {reindex_metrics_config: "/etc/catalog/reindex/solr_metrics.xml"} }

        it { is_expected.to contain_file("/etc/systemd/system/metrics-catalog-reindex.service").with_content(/ExecStart=.*\s-f \/etc\/catalog\/reindex\/solr_metrics\.xml\s/) }
      end
    end
  end
end
