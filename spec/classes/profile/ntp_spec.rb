# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::ntp" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pools) { "/etc/chrony/sources.d/local-pools.sources" }
      let(:servers) { "/etc/chrony/sources.d/local-servers.sources" }
      let(:ntp_opts) { " iburst" }

      it "does not configure ntpd" do
        is_expected.not_to contain_class("ntp")
        is_expected.not_to contain_service("ntp")
        is_expected.not_to contain_file("/etc/ntp.conf")
        is_expected.not_to contain_file("/etc/ntpsec/ntp.conf")
      end

      it "purges deprecated and conflicting ntp packages" do
        %i[ntp ntpsec sntp ntpstat systemd-timesyncd].each do |package|
          is_expected.to contain_package(package).with_ensure("purged")
        end
      end

      it "installs chrony" do
        is_expected.to contain_package("chrony")
        is_expected.to contain_service("chrony")
          .that_requires("Package[chrony]")
        is_expected.to contain_file("/etc/chrony/chrony.conf")
          .with_source("puppet:///modules/nebula/chrony/chrony.conf")
          .that_requires("Package[chrony]")
          .that_notifies("Service[chrony]")
      end

      it "deletes unmanaged drop in configs" do
        %i[conf.d sources.d].each do |dir|
          is_expected.to contain_file("/etc/chrony/#{dir}/")
            .with_ensure("directory")
            .that_requires("Package[chrony]")
            .that_notifies("Service[chrony]")
        end
      end

      context "with default hiera data" do
        it "writes pool to source config" do
          is_expected.to contain_file(pools)
            .with_content(/^pool ntp.example.invalid#{ntp_opts}$/)
        end
      end

      context "with pools, blank servers" do
        let(:params) do
          {
            pools: ["time.com", "time.net"],
            servers: []
          }
        end

        it "writes pools source config" do
          is_expected.to contain_file(pools)
            .with_content(/^pool time.com#{ntp_opts}$/)
            .with_content(/^pool time.net#{ntp_opts}$/)
        end
      end

      context "with servers only" do
        let(:params) do
          {servers: ["foo.com", "bar.com"]}
        end

        it "writes pools from heira data to source config" do
          is_expected.to contain_file(pools)
            .with_content(/^pool ntp.example.invalid#{ntp_opts}$/)
        end
        it "writes servers source config" do
          is_expected.to contain_file(servers)
            .with_content(/^server foo.com#{ntp_opts}$/)
            .with_content(/^server bar.com#{ntp_opts}$/)
        end
      end

      context "with servers and pools" do
        let(:params) do
          {
            pools: ["time.com", "time.net"],
            servers: ["10.1.1.1", "10.2.2.2"]
          }
        end

        it "writes pools source config" do
          is_expected.to contain_file(pools)
            .with_content(/^pool time.com#{ntp_opts}$/)
            .with_content(/^pool time.net#{ntp_opts}$/)
        end
        it "writes servers source config" do
          is_expected.to contain_file(servers)
            .with_content(/^server 10.1.1.1#{ntp_opts}$/)
            .with_content(/^server 10.2.2.2#{ntp_opts}$/)
        end
      end

      context "default facts" do
        it "enables leap second handling" do
          is_expected.to contain_file("/etc/chrony/conf.d/leapsectz.conf")
            .with_source("puppet:///modules/nebula/chrony/leapsectz.conf")
        end
      end

      context "in aws" do
        # let(:facts) { os_facts.merge(datacenter: "mydatacenter") }
        let(:facts) { os_facts.merge("cloud" => {"provider" => "aws"}) }

        it "disables leap second handling" do
          is_expected.not_to contain_file("/etc/chrony/conf.d/leapsectz.conf")
        end
      end
    end
  end
end
