# frozen_string_literal: true

# Copyright (c) 2025 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::search::catalog::solr" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(mlibrary_ip_addresses: {
          "public" => [os_facts[:networking]["ip"]],
          "private" => []
        })
      end

      it { is_expected.to compile }

      it { is_expected.to contain_file("/l").with_ensure("directory") }
      it { is_expected.to contain_file("/l/solr-vufind").with_ensure("link") }
      it { is_expected.to contain_file("/l/solr-vufind").with_target("/var/lib/vufind") }

      it { is_expected.to contain_service("solr-catalog-serve") }
      it { is_expected.not_to contain_service("solr-catalog-reindex") }

      it { is_expected.to contain_exec("catalog serve solr reload systemd").that_notifies("Service[solr-catalog-serve]") }
      it { is_expected.to contain_exec("catalog reindex solr reload systemd") }

      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/ExecStart=\/opt\/catalog\/serve\/bin\/solr start -p 8983 -m 1g/) }
      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/ExecStop=\/opt\/catalog\/serve\/bin\/solr stop/) }
      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/ExecStart=\/opt\/catalog\/reindex\/bin\/solr start -p 8984 -m 1g/) }
      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/ExecStop=\/opt\/catalog\/reindex\/bin\/solr stop/) }

      context "when serve_bin is set to /usr/bin/solr" do
        let(:params) { {serve_bin: "/usr/bin/solr"} }

        it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/ExecStart=\/usr\/bin\/solr start/) }
        it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/ExecStop=\/usr\/bin\/solr stop/) }
      end

      context "when serve_port is set to 8765" do
        let(:params) { {serve_port: 8765} }

        it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/ExecStart=.+\s-p 8765\s/) }
      end

      context "when serve_max_heap_size is set to 10g" do
        let(:params) { {serve_max_heap_size: "10g"} }

        it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/ExecStart=.+\s-m 10g\s/) }
      end

      context "when reindex_bin is set to /usr/bin/solr" do
        let(:params) { {reindex_bin: "/usr/bin/solr"} }

        it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/ExecStart=\/usr\/bin\/solr start/) }
        it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/ExecStop=\/usr\/bin\/solr stop/) }
      end

      context "when reindex_port is set to 8765" do
        let(:params) { {reindex_port: 8765} }

        it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/ExecStart=.+\s-p 8765\s/) }
      end

      context "when reindex_max_heap_size is set to 10g" do
        let(:params) { {reindex_max_heap_size: "10g"} }

        it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/ExecStart=.+\s-m 10g\s/) }
      end
    end
  end
end
