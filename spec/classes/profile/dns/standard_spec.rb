# frozen_string_literal: true

# Copyright (c) 2018 The Regents of the University of Michigan.
# All Rights Reserved. Licensed according to the terms of the Revised
# BSD License. See LICENSE.txt for details.
require "spec_helper"

describe "nebula::profile::dns::standard" do
  on_supported_os(supported_os: Nebula.supported_os).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        expect(subject).to contain_class("nebula::resolv_conf").with_nameservers(
          ["5.5.5.5", "4.4.4.4"]
        ).with_searchpath(["searchpath.default.invalid"])
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
      end
    end
  end
end
