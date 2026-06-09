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
      it { is_expected.to contain_file("/l/solr-vufind").with_target("/home/nebula-hiera-default-search-solr-user") }

      if os.start_with?("debian-11")
        it { is_expected.not_to contain_group("search-catalog-solr") }
        it { is_expected.not_to contain_user("nebula-hiera-default-search-solr-user") }
        it { is_expected.not_to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh") }
        it { is_expected.not_to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh/authorized_keys") }
      else
        it { is_expected.to contain_group("search-catalog-solr").with_gid(1000) }
        it { is_expected.to contain_user("nebula-hiera-default-search-solr-user").that_requires("Group[search-catalog-solr]") }
        it { is_expected.to contain_user("nebula-hiera-default-search-solr-user").with_uid(1000) }
        it { is_expected.to contain_user("nebula-hiera-default-search-solr-user").with_gid("search-catalog-solr") }
        it { is_expected.to contain_user("nebula-hiera-default-search-solr-user").with_home("/home/nebula-hiera-default-search-solr-user") }
        it { is_expected.to contain_user("nebula-hiera-default-search-solr-user").with_managehome(true) }
        it { is_expected.to contain_user("nebula-hiera-default-search-solr-user").with_shell("/bin/bash") }
        it { is_expected.to contain_user("nebula-hiera-default-search-solr-user").with_comment("Search Catalog Solr User") }

        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh").with_ensure("directory") }
        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh").with_mode("0700") }
        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh").with_owner("nebula-hiera-default-search-solr-user") }
        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh").with_group("search-catalog-solr") }
        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh").that_requires("User[nebula-hiera-default-search-solr-user]") }

        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh/authorized_keys").with_content("") }
        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh/authorized_keys").with_owner("nebula-hiera-default-search-solr-user") }
        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh/authorized_keys").with_group("search-catalog-solr") }
        it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh/authorized_keys").that_requires("File[/home/nebula-hiera-default-search-solr-user/.ssh]") }

        it { is_expected.to contain_exec("/home/nebula-hiera-default-search-solr-user/.ssh/id_ed25519").with_command("/usr/bin/ssh-keygen -t ed25519 -N '' -f /home/nebula-hiera-default-search-solr-user/.ssh/id_ed25519") }
        it { is_expected.to contain_exec("/home/nebula-hiera-default-search-solr-user/.ssh/id_ed25519").with_creates("/home/nebula-hiera-default-search-solr-user/.ssh/id_ed25519") }
        it { is_expected.to contain_exec("/home/nebula-hiera-default-search-solr-user/.ssh/id_ed25519").with_user("nebula-hiera-default-search-solr-user") }
        it { is_expected.to contain_exec("/home/nebula-hiera-default-search-solr-user/.ssh/id_ed25519").that_requires("File[/home/nebula-hiera-default-search-solr-user/.ssh]") }
      end

      it { is_expected.to contain_service("solr-catalog-serve") }
      it { is_expected.not_to contain_service("solr-catalog-reindex") }

      it { is_expected.to contain_exec("catalog serve solr reload systemd").that_notifies("Service[solr-catalog-serve]") }
      it { is_expected.to contain_exec("catalog reindex solr reload systemd") }

      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/ExecStart=\/opt\/catalog\/serve\/bin\/solr start -p 8983 -m 1g/) }
      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/ExecStop=\/opt\/catalog\/serve\/bin\/solr stop/) }
      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/ExecStart=\/opt\/catalog\/reindex\/bin\/solr start -p 8984 -m 1g/) }
      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/ExecStop=\/opt\/catalog\/reindex\/bin\/solr stop/) }

      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/User=nebula-hiera-default-search-solr-user/) }
      it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/User=nebula-hiera-default-search-solr-user/) }

      if os.start_with?("debian-11")
        it { is_expected.not_to contain_file("/etc/sudoers.d/solr-catalog") }
      else
        it { is_expected.to contain_file("/etc/sudoers.d/solr-catalog").with_mode("0440") }
        it { is_expected.to contain_file("/etc/sudoers.d/solr-catalog").with_content(/^%search-catalog-solr ALL/) }
      end

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

      unless os.start_with?("debian-11")
        context "with solr_user.name set to abc" do
          let(:params) { {solr_user: {"name" => "abc"}} }

          it { is_expected.to compile }
          it { is_expected.not_to contain_user("search-catalog-solr") }
          it { is_expected.to contain_user("abc").that_requires("Group[search-catalog-solr]") }
          it { is_expected.to contain_user("abc").with_home("/home/abc") }
          it { is_expected.to contain_file("/l/solr-vufind").with_target("/home/abc") }
          it { is_expected.to contain_file("/home/abc/.ssh").with_owner("abc") }
          it { is_expected.to contain_file("/home/abc/.ssh/authorized_keys").with_owner("abc") }
          it { is_expected.to contain_exec("/home/abc/.ssh/id_ed25519").with_user("abc") }
          it { is_expected.to contain_exec("/home/abc/.ssh/id_ed25519").with_command("/usr/bin/ssh-keygen -t ed25519 -N '' -f /home/abc/.ssh/id_ed25519") }
          it { is_expected.to contain_exec("/home/abc/.ssh/id_ed25519").with_creates("/home/abc/.ssh/id_ed25519") }
          it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-serve.service").with_content(/User=abc/) }
          it { is_expected.to contain_file("/etc/systemd/system/solr-catalog-reindex.service").with_content(/User=abc/) }
        end

        context "with solr_user.uid set to 5678" do
          let(:params) { {solr_user: {"uid" => 5678}} }

          it { is_expected.to compile }
          it { is_expected.to contain_user("search-catalog-solr").with_uid(5678) }
        end

        context "with solr_user.home set to /opt/solr" do
          let(:params) { {solr_user: {"home" => "/opt/solr"}} }

          it { is_expected.to compile }
          it { is_expected.to contain_user("search-catalog-solr").with_home("/opt/solr") }
          it { is_expected.to contain_file("/l/solr-vufind").with_target("/opt/solr") }
          it { is_expected.to contain_file("/opt/solr/.ssh").with_owner("search-catalog-solr") }
          it { is_expected.to contain_file("/opt/solr/.ssh/authorized_keys").with_owner("search-catalog-solr") }
          it { is_expected.to contain_exec("/opt/solr/.ssh/id_ed25519").with_user("search-catalog-solr") }
          it { is_expected.to contain_exec("/opt/solr/.ssh/id_ed25519").with_command("/usr/bin/ssh-keygen -t ed25519 -N '' -f /opt/solr/.ssh/id_ed25519") }
          it { is_expected.to contain_exec("/opt/solr/.ssh/id_ed25519").with_creates("/opt/solr/.ssh/id_ed25519") }
        end

        context "with solr_user.comment set to Solr User" do
          let(:params) { {solr_user: {"comment" => "Solr User"}} }

          it { is_expected.to compile }
          it { is_expected.to contain_user("search-catalog-solr").with_comment("Solr User") }
        end

        context "with solr_user.group_name set to abc" do
          let(:params) { {solr_user: {"group_name" => "abc"}} }

          it { is_expected.to compile }

          it { is_expected.not_to contain_group("search-catalog-solr") }
          it { is_expected.to contain_group("abc").with_gid(1000) }
          it { is_expected.to contain_user("search-catalog-solr").that_requires("Group[abc]") }
          it { is_expected.to contain_user("search-catalog-solr").with_gid("abc") }
          it { is_expected.to contain_file("/home/search-catalog-solr/.ssh").with_group("abc") }
          it { is_expected.to contain_file("/home/search-catalog-solr/.ssh/authorized_keys").with_group("abc") }

          it { is_expected.not_to contain_file("/etc/sudoers.d/solr-catalog").with_content(/^%search-catalog-solr ALL/) }
          it { is_expected.to contain_file("/etc/sudoers.d/solr-catalog").with_content(/^%abc ALL/) }
        end

        context "with solr_user.gid set to 1234" do
          let(:params) { {solr_user: {"gid" => 1234}} }

          it { is_expected.to compile }
          it { is_expected.to contain_group("search-catalog-solr").with_gid(1234) }
        end

        context "with authorized_keys set to abc" do
          let(:params) { {authorized_keys: "abc\n"} }

          it { is_expected.to compile }
          it { is_expected.to contain_file("/home/nebula-hiera-default-search-solr-user/.ssh/authorized_keys").with_content("abc\n") }
        end
      end
    end
  end
end
