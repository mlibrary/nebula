# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::apt::nodejs" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it "doesn't install nodejs" do
        is_expected.not_to contain_package("nodejs")
      end

      it "configures nodejs apt source" do
        is_expected.to contain_apt__source("nodesource.com")
          .with_source_format("sources")
          .with_location(["https://deb.nodesource.com/node_22.x"])
          .with_release("nodistro")
          .with_keyring("/etc/apt/keyrings/nodesource.asc")
      end

      it "configures nodejs apt keyring" do
        is_expected.to contain_apt__keyring("nodesource.asc")
          .with_source("puppet:///modules/nebula/apt/keyrings/nodesource.asc")
      end

      context "nodejs 10" do
        let(:params) do
          {version: 10}
        end

        it "fails" do
          is_expected.not_to compile
        end
      end

      context "nodejs 14" do
        let(:params) do
          {version: 14}
        end

        it "fails" do
          is_expected.not_to compile
        end
      end

      context "nodejs 18" do
        let(:params) do
          {version: 18}
        end

        case os
        when "debian-11-x86_64", "ubuntu-22.04-x86_64"
          it "configures repo" do
            is_expected.to contain_apt__source("nodesource.com")
              .with_location(["https://deb.nodesource.com/node_18.x"])
              .with_release("nodistro")
          end

          it "configures nodejs apt keyring" do
            is_expected.to contain_apt__keyring("nodesource.asc")
              .with_source("puppet:///modules/nebula/apt/keyrings/nodesource.asc")
          end
        when "debian-12-x86_64", "ubuntu-24.04-x86_64"
          it "uses os repo" do
            is_expected.not_to contain_apt__source("nodesource.com")
          end
        else
          it "fails" do
            is_expected.not_to compile
          end
        end
      end

      context "nodejs 20" do
        let(:params) do
          {version: 20}
        end

        case os
        when "debian-11-x86_64", "ubuntu-22.04-x86_64", "debian-12-x86_64", "ubuntu-24.04-x86_64"
          it "configures repo" do
            is_expected.to contain_apt__source("nodesource.com")
              .with_location(["https://deb.nodesource.com/node_20.x"])
              .with_release("nodistro")
          end

          it "configures nodejs apt keyring" do
            is_expected.to contain_apt__keyring("nodesource.asc")
              .with_source("puppet:///modules/nebula/apt/keyrings/nodesource.asc")
          end
        when "debian-13-x86_64"
          it "uses os repo" do
            is_expected.not_to contain_apt__source("nodesource.com")
          end
        else
          it "fails" do
            is_expected.not_to compile
          end
        end
      end

      context "nodejs 22" do
        let(:params) do
          {version: 22}
        end

        case os
        when "debian-11-x86_64", "ubuntu-22.04-x86_64", "debian-12-x86_64", "ubuntu-24.04-x86_64", "debian-13-x86_64"
          it "configures repo" do
            is_expected.to contain_apt__source("nodesource.com")
              .with_location(["https://deb.nodesource.com/node_22.x"])
              .with_release("nodistro")
          end

          it "configures nodejs apt keyring" do
            is_expected.to contain_apt__keyring("nodesource.asc")
              .with_source("puppet:///modules/nebula/apt/keyrings/nodesource.asc")
          end
        else
          it "fails" do
            is_expected.not_to compile
          end
        end
      end
    end
  end
end
