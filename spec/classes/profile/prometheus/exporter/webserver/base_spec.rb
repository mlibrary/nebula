# frozen_string_literal: true

# Copyright (c) 2024 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require 'spec_helper'

describe 'nebula::profile::prometheus::exporter::webserver::base' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.not_to compile }

      context "with target set to abcd" do
        let(:params) { { target: "abcd" } }

        def have_script
          contain_file("/usr/local/lib/prom_web_exporter/metrics")
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_package("mariadb-client") }
        it { is_expected.to contain_file("/usr/local/lib/prom_web_exporter").with_ensure("directory") }
        it { is_expected.to have_script.with_mode("0755") }
        it { is_expected.to have_script.with_content(/^#!\/usr\/bin\/env bash$/) }
        it { is_expected.to have_script.with_content(/^ENABLE_MARIADB_CHECK="false"$/) }
        it { is_expected.to have_script.with_content(/^NFS_MOUNTS=\(\)$/) }
        it { is_expected.to have_script.with_content(/^SOLR_INSTANCES=\(\)$/) }
        it { is_expected.to have_script.with_content(/^ENABLE_SHIBD_CHECK="false"$/) }

        context "with mariadb credentials set" do
          let(:params) do
            super().merge({ mariadb_connect: { "abcd" => {
              "hostname" => "abcd-db-host",
              "database" => "abcd-database",
              "username" => "abcd-db-monitor",
              "password" => "random-password",
            }}})
          end

          it { is_expected.to contain_package("mariadb-client") }
          it { is_expected.to have_script.with_content(/^ENABLE_MARIADB_CHECK="true"$/) }
        end

        context "with nfs mounts set" do
          let(:params) do
            super().merge({ nfs_mounts: { "abcd" => %w[/abc /def /ghi] } })
          end

          it { is_expected.to have_script.with_content(/^NFS_MOUNTS=\("\/abc" "\/def" "\/ghi"\)$/) }
        end

        context "with solr instances set" do
          let(:params) do
            super().merge({ solr_instances: { "abcd" => ["http://solr/solr/core"] } })
          end

          it { is_expected.to have_script.with_content(/^SOLR_INSTANCES=\("http:\/\/solr\/solr\/core"\)$/) }
        end

        context "with shibd check enabled" do
          let(:params) do
            super().merge({ check_shibd: { "abcd" => true } })
          end

          it { is_expected.to have_script.with_content(/^ENABLE_SHIBD_CHECK="true"$/) }
        end
      end
    end
  end
end
