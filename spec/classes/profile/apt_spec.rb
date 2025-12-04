# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::apt" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os.start_with? "debian"
        it do
          expect(subject).to contain_class("apt").with(
            purge: {
              "sources.list" => true,
              "sources.list.d" => true,
              "preferences" => true,
              "preferences.d" => true
            },
            update: {
              "frequency" => "daily"
            }
          )
        end

        it "sets apt to never install recommended packages" do
          expect(subject).to contain_file("/etc/apt/apt.conf.d/99no-recommends")
            .with_content(%r{^APT::Install-Recommends "0";$})
            .with_content(%r{^APT::Install-Suggests "0";$})
        end

        it do
          expect(subject).to contain_apt__source("main").with(
            location: "http://ftp.us.debian.org/debian/",
            repos: case os
                   when "debian-12-x86_64"
                     "main contrib non-free non-free-firmware"
                   else
                     "main contrib non-free"
                   end
          )
        end

        it do
          expect(subject).to contain_apt__source("security").with(
            repos: case os
                   when "debian-12-x86_64"
                     "main contrib non-free non-free-firmware"
                   else
                     "main contrib non-free"
                   end
          )
        end

        it do
          expect(subject).to contain_apt__source("security").with_release(
            case os
            when "debian-9-x86_64"
              "#{facts[:lsbdistcodename]}/updates"
            when "debian-10-x86_64"
              "#{facts[:lsbdistcodename]}/updates"
            else
              "#{facts[:lsbdistcodename]}-security"
            end
          )
        end

        it do
          expect(subject).to contain_file("/etc/apt/apt.conf.d/99force-ipv4")
            .with_content(%r{^Acquire::ForceIPv4 "true";$})
        end

        context "when given a mirror of http://debian.uchicago.edu/" do
          let(:params) { {mirror: "http://debian.uchicago.edu/"} }

          it do
            expect(subject).to contain_apt__source("main")
              .with_location("http://debian.uchicago.edu/")
          end
        end

        context "when given a puppet_repo of PC1" do
          let(:params) { {puppet_repo: "PC1"} }

          it { is_expected.to contain_apt__source("openvox").with_repos("PC1") }
        end
      end

      it {
        is_expected.to contain_apt__source("local")
          .with_architecture("amd64")
          .with_location("https://local-repo.default-invalid/debian")
      }

      case os
      when %r{^debian}
        it do
          expect(subject).to contain_apt__source("security")
            .with_location("http://security.debian.org/debian-security")
        end

        it do
          expect(subject).to contain_apt__source("updates").with(
            location: "http://ftp.us.debian.org/debian/",
            release: "#{facts[:lsbdistcodename]}-updates",
            repos: case os
                   when "debian-12-x86_64"
                     "main contrib non-free non-free-firmware"
                   else
                     "main contrib non-free"
                   end
          )
        end

        context "when given a local repo" do
          let(:params) do
            {repos:
              {
                "foobar" =>
                  {
                    "location" => "https://foobar.example.invalid/debs",
                    "key" => {"name" => "foobar.asc", "source" => "https://foobar.example.invalid/key.asc"}
                  },
                "foobaz" =>
                  {
                    "location" => "https://www.foobaz.invalid/repo",
                    "key" => {"name" => "baz.gpg", "source" => "https://www.foobaz.invalid/key.gpg"}
                  }
              }}
          end

          it do
            expect(subject).not_to contain_apt__source("local")
            expect(subject).to contain_apt__source("foobar").with(
              location: "https://foobar.example.invalid/debs",
              architecture: "amd64",
              release: facts[:lsbdistcodename].to_s,
              repos: "main"
            )
            expect(subject).to contain_apt__source("foobaz").with(
              location: "https://www.foobaz.invalid/repo"
            )
          end
        end

        it { is_expected.not_to contain_class("apt::backports") }

        context "when abc is installed from backports" do
          let(:facts) { os_facts.merge(installed_backports: ["abc"]) }

          it do
            expect(subject).to contain_class("apt::backports")
              .with_location("http://ftp.us.debian.org/debian/")
          end
        end
      when %r{^ubuntu}
        it do
          expect(subject).to contain_apt__source("main")
            .with_location("http://us.archive.ubuntu.com/ubuntu")
            .with_repos("main restricted universe")
            .with_release(facts[:lsbdistcodename].to_s)
          expect(subject).to contain_apt__source("updates")
            .with_location("http://us.archive.ubuntu.com/ubuntu")
            .with_repos("main restricted universe")
            .with_release("#{facts[:lsbdistcodename]}-updates")
          expect(subject).to contain_apt__source("security")
            .with_location("http://us.archive.ubuntu.com/ubuntu")
            .with_repos("main restricted universe")
            .with_release("#{facts[:lsbdistcodename]}-security")
          expect(subject).to contain_apt__source("backports")
            .with_location("http://us.archive.ubuntu.com/ubuntu")
            .with_repos("main restricted universe")
            .with_release("#{facts[:lsbdistcodename]}-backports")
        end

        it "disables 20apt-esm-hook.conf" do
          is_expected.to contain_exec("disable 20apt-esm-hook.conf")
            .with_creates("/etc/apt/apt.conf.d/20apt-esm-hook.conf.disabled")
            .with_command("/usr/bin/dpkg-divert --rename --divert /etc/apt/apt.conf.d/20apt-esm-hook.conf.disabled --add /etc/apt/apt.conf.d/20apt-esm-hook.conf")
        end
      end

      it { is_expected.not_to contain_apt__source("hpe") }

      context "when on an HPE machine" do
        let(:facts) { os_facts.merge("dmi" => {"manufacturer" => "HPE"}) }

        it do
          expect(subject).to contain_apt__source("hpe").with(
            location: "https://downloads.linux.hpe.com/SDR/repo/mcp",
            release: "#{facts[:lsbdistcodename]}/current",
            repos: "non-free"
          )
        end

        context "with ubuntu instead of debian" do
          let(:facts) do
            os_facts.merge("dmi" => {"manufacturer" => "HPE"},
              "operatingsystem" => "Ubuntu")
          end

          it do
            expect(subject).to contain_apt__source("hpe").with(
              location: "https://downloads.linux.hpe.com/SDR/repo/mcp",
              release: "#{facts[:lsbdistcodename]}/current",
              repos: "non-free"
            )
          end
        end
      end

      case os
      when /^debian-/
        it "uses correct openvox release for debian" do
          is_expected.to contain_apt__source("openvox").with(
            location: "https://apt.voxpupuli.org",
            repos: "openvox5",
            release: "debian#{facts[:os]["release"]["major"]}"
          )
        end
      when /^ubuntu-/
        it "uses correct openvox release for ubuntu" do
          is_expected.to contain_apt__source("openvox").with(
            location: "https://apt.voxpupuli.org",
            repos: "openvox5",
            release: "ubuntu#{facts[:os]["release"]["major"]}"
          )
        end
      end
    end
  end
end
