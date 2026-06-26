# frozen_string_literal: true

require "spec_helper"

describe "nebula::profile::mariadb::server" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it "configures mariadb apt source" do
        is_expected.to contain_apt__source("mariadb")
      end

      it "installs mariadb-server, mariadb-backup" do
        is_expected.to contain_package("mariadb-server").that_requires("Package[mariadb-client]")
        is_expected.to contain_package("mariadb-backup").that_requires("Package[mariadb-client]")
      end

      it "configures mariadb-server" do
        is_expected.to contain_file("/etc/mysql/mariadb.conf.d/90-mlibrary.cnf")
          .with_content(/^\[mysqld\]$/)
          .that_notifies("Service[mariadb]")

        is_expected.to contain_service("mariadb").that_requires("Package[mariadb-server]")
      end

      it "no default nfs backup" do
        is_expected.not_to contain_mount("/mnt/backup")
      end
      it { is_expected.not_to contain_package("nfs-common") }

      context "with backup_nfs_target set" do
        let(:params) do
          {backup_nfs_target: "example.invalid:/some/nfs/path"}
        end

        it "creates backup dir" do
          is_expected.to contain_file("/mnt/backup")
            .with_ensure("directory")
        end

        it "mounts nfs backup volume" do
          is_expected.to contain_mount("/mnt/backup")
            .with_device("example.invalid:/some/nfs/path")
        end

        it { is_expected.to contain_package("nfs-common") }
      end
    end
  end
end
