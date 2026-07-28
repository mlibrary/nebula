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

      it "installs rsync" do
        is_expected.to contain_package("rsync")
      end

      it "removes /usr/bin/mariabackup symlink" do
        is_expected.to contain_file("/usr/bin/mariabackup").with_ensure("absent")
      end

      it "configures mariadb-server" do
        is_expected.to contain_file("/etc/mysql/mariadb.conf.d/90-mlibrary.cnf")
          .with_content(/^\[mysqld\]$/)
          .that_notifies("Service[mariadb]")

        is_expected.to contain_service("mariadb").that_requires("Package[mariadb-server]")
      end

      it "no default nfs backup" do
        is_expected.not_to contain_mount("/mnt/backup")
        is_expected.to contain_cron__job("backup_db").with_ensure("absent")
        is_expected.not_to contain_package("nfs-common")
      end

      it "removes backup_db when nfs mount not configured" do
        is_expected.to contain_file("/usr/local/bin/backup_db").with_ensure("absent")
      end

      context "with backup_nfs_target, backup_ignore_table* set" do
        let(:params) do
          {
            backup_nfs_target: "example.invalid:/some/nfs/path",
            backup_ignore_table: ["ephemeral.table", "some_db.just_cache_here"],
            backup_ignore_table_data: "important_db.with_unimportant_data"
          }
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
        it { is_expected.to contain_package("zstd") }

        it "installs backup_db script, w/ --ignore-table flags" do
          is_expected.to contain_file("/usr/local/bin/backup_db")
            .with_content(%r{^BACKUP_DIR='/mnt/backup/foo'$})
            .with_content(/--ignore-table=some_db.just_cache_here/)
            .with_content(/--ignore-table-data=important_db.with_unimportant_data/)
        end
        it "deletes backup_db cron" do
          is_expected.to contain_cron__job("backup_db").with_ensure("absent")
        end
      end

      context "with backup_nfs_target, backup_cron_weekday, and backup_path set" do
        let(:params) do
          {
            backup_nfs_target: "example.invalid:/some/nfs/path",
            backup_cron_weekday: "1,3,5",
            backup_path: "/some/random/path"
          }
        end

        it "installs backup_db script, w/o --ignore-table flags" do
          is_expected.to contain_file("/usr/local/bin/backup_db")
            .with_content(%r{^BACKUP_DIR='/some/random/path/foo'$})
            .with_content(/--user=root \\\n  \| zstd/)
        end
        it "creates backup_db cron job" do
          is_expected.to contain_cron__job("backup_db")
            .with_command("/usr/local/bin/backup_db")
            .with_description(%r{backup mariadb to /some/random/path$})
        end
        it { is_expected.to contain_mount("/some/random/path") }
      end

      [
        [" foo.bar", "some_db.just_cache_here"],
        ["foo.bar", "not.areal.table"],
        ["foo.bar", ""],
        ""
      ].each do |tables|
        [:backup_ignore_table, :backup_ignore_table_data].each do |p|
          context "invalid #{p}: '#{tables}'" do
            let(:params) do
              {:backup_nfs_target => "example.invalid:/some/nfs/path", p => tables}
            end
            it { is_expected.not_to compile }
          end
        end
      end

      context "valid backup_ignore_table: 'some.table'" do
        let(:params) do
          {backup_nfs_target: "example.invalid:/some/nfs/path", backup_ignore_table: "some.table"}
        end
        it { is_expected.to contain_file("/usr/local/bin/backup_db").with_content(/--ignore-table=some.table/).without_content(/--ignore-table-data=some.table/) }
      end
      context "valid backup_ignore_table_data: 'some.table'" do
        let(:params) do
          {backup_nfs_target: "example.invalid:/some/nfs/path", backup_ignore_table_data: "some.table"}
        end
        it { is_expected.to contain_file("/usr/local/bin/backup_db").without_content(/--ignore-table=some.table/).with_content(/--ignore-table-data=some.table/) }
      end

      context "with backup_cron_weekday set (but no backup_nfs_target)" do
        let(:params) do
          {backup_cron_weekday: "1,3,5"}
        end
        it { is_expected.not_to compile }
      end
    end
  end
end
