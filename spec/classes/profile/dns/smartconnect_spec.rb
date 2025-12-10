# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::dns::smartconnect" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it "has no bind package" do
        is_expected.not_to contain_package("nebula::profile::dns::smartconnect::bind9")
        is_expected.not_to contain_package("bind9")
        is_expected.not_to contain_service("bind9")
      end

      it do
        expect(subject).to contain_class("nebula::resolv_conf").with_nameservers(
          [
            "5.5.5.5",    # nebula::resolv_conf::nameservers[0]
            "4.4.4.4"    # nebula::resolv_conf::nameservers[1]
          ]
        ).with_searchpath(["searchpath.default.invalid"])
        is_expected.not_to contain_class("nebula::resolv_conf")
          .with_require("Service[bind9]")
      end

      it "removes resolvconf package if present" do
        expect(subject).to contain_package("resolvconf").with_ensure("absent")
      end

      it "contains expected resolv.conf file" do
        expect(subject).to contain_file("/etc/resolv.conf")
          .with_content(%r{^#.*puppet})
          .with_content(%r{^search searchpath\.default\.invalid$})
          .with_content(%r{^nameserver 5.5.5.5$})
          .with_content(%r{^nameserver 4.4.4.4$})
        is_expected.not_to contain_file("/etc/resolv.conf")
          .with_content(%r{^nameserver 127.0.0.1$})
      end

      [
        "/etc/bind/named.conf",
        "/etc/bind/named.conf.local",
        "/etc/bind/named.conf.options"
      ].each do |name|
        it { is_expected.not_to contain_file(name) }
      end
    end
  end
end
