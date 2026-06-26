# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::mariadb" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it "configures mariadb apt source" do
        is_expected.to contain_apt__source("mariadb")
          .with_location(["https://deb.mariadb.org/12.3/#{facts[:os]["name"].downcase}"])
        is_expected.to contain_apt__keyring("mariadb.asc")
      end

      it "installs mariadb client" do
        is_expected.to contain_package("mariadb-client")
          .that_requires("Apt::Source[mariadb]")
      end

      context "with apt_mirror and version set" do
        let(:params) do
          {version: "99.rolling", apt_mirror: "https://mirror.example.com"}
        end

        it "sets custom mariadb mirror and version" do
          is_expected.to contain_apt__source("mariadb")
            .with_location([
              "https://mirror.example.com/mariadb/repo/99.rolling/#{facts[:os]["name"].downcase}",
              "https://deb.mariadb.org/99.rolling/#{facts[:os]["name"].downcase}"
            ])
        end
      end
    end
  end
end
